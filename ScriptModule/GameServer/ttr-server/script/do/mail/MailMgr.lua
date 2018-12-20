
local MailData = TableMail

MailMgr = CreateClass("MailMgr")

MailMgr = {
	owner = nil,
	id = 0,
	loaded = false,
	mails = nil,
}

MAIL_MAX = 100
MAIL_KEEP_TIME = 604800 -- 7 * 24 * 3600

function MailMgr:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function MailMgr:init(owner)
	self.owner = owner
	self.loaded = false
	self.mails = {}
end

function MailMgr:receive(id)
	self:pull()

	local mail_found = nil

	for _, mail in ipairs(self.mails) do
		if mail.id == id then
			mail_found = mail
			break
		end
	end
	
	if mail_found == nil then
		return ERROR_CODE.ID_NOT_FOUND
	end

	--
	local mailtype = tonumber(mail_found.mailType)
	local maildata = MailData[mailtype]
	--处理打开获得道具
	if maildata ~= nil and mailtype > 1 then
		local args = string.split(maildata.Attachments, ';')
		for k,v in pairs(args) do
			local aargs = string.split(v, '_')
			local aitemid = aargs[1]
			local aitemnum = aargs[2]
			UserItems:useItem(self.owner,tonumber(aitemid),tonumber(aitemnum))
		end
	else
		local args = string.split(mail_found.Attachments, ';')
		for k,v in pairs(args) do
			local aargs = string.split(v, '_')
			local aitemid = aargs[1]
			local aitemnum = aargs[2]
			UserItems:useItem(self.owner,tonumber(aitemid),tonumber(aitemnum))
		end
	end

	mail_found.read = true
	return 0
end

function MailMgr:pull()
	if not self.loaded then
		self:loadFromDb()
		self:clean()
	end

	return self.mails
end

function MailMgr:clean()
	local indexes = {}
	local time = os.time()

	for i, mail in ipairs(self.mails) do
		if time - mail.time > MSG_KEEP_TIME then
			table.insert(indexes, i)
		end
	end

	local i = 0
	while #indexes > 0 do
		i = table.remove(indexes, #indexes)
		table.remove(self.mails, 1)
	end

	while #self.mails > MAIL_MAX do
		table.remove(self.mails, 1)
	end
end

--attachment{itemId, number}
function MailMgr:add(mailType, subject, content, attachments)
	if not self.loaded then
		self:loadFromDb()
		self:clean()
	end

	self.id = self.id + 1

	local mail = mailsys.create(self.id, mailType, subject, content, attachments)
	table.insert(self.mails, mail)

	while (#self.mails >= MAIL_MAX) do
		unilight.debug("mails is more than " .. MAIL_MAX .. ", remove the first")
		table.remove(self.mails, 1)
	end

	return mail
end

function MailMgr:addNew(mailType, subject, content, attachments)
	local mail = self:add(mailType, subject, content, attachments)
	
	--push client
	local res = {}
	res["do"] = "Cmd.MailNewCmd_S"
	res["data"] = {
		mail = mail
	}

	unilight.response(self.owner.laccount, res)
end

function MailMgr:saveToDb()
	if not self.loaded then
		return
	end

	local data = {
		uid = self.owner.uid,
		id = self.id,
		mails = self.mails,
	}

	unilight.savedata(mailsys.MAIL_DB, data)
end

function MailMgr:loadFromDb()
	local data = unilight.getdata(mailsys.MAIL_DB, self.owner.uid)

	if data ~= nil then
		--Safty: In the case, data is not nil, but data.id or data.mails is nil
		if data.id ~= nil then
			self.id = data.id
		end

		if self.mails ~= nil then
			self.mails = data.mails
		end
	end

	self.loaded = true
end
