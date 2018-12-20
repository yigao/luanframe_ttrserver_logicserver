mailsys = {}

--[[
mail = {
	id = 0,
	mailType = 0,
	read = false,
	time = 0,
	subject = "",
	text = "",
	attachments = {},
}
--]]

mailsys.MAIL_DB = "mail"
mailsys.MAIL_TYPE_CUSTOM = 1

function mailsys.create(id, mailType, subject, text, attachments)
	local mail = {
		id = id,
		mailType = mailType,
		read = false,
		time = os.time()
	}

	if mailType == MAIL_TYPE_CUSTOM then
		if subject ~= nil and type(subject) == 'string' then
			mail.subject = subject
		end

		if text ~= nil and type(text) == 'string' then
			mail.text = text
		end

		if attachments ~= nil then
			mail.attachments = attachments
		end
	else
	end

	return mail
end

function mailsys.sendCustom(uid, subject, content, attachments)
	local userInfo = GetUserInfoById(uid)

	if userInfo == nil then
		local mail = create(0, 1, subject, content, attachments)
		save(uid, mail)
	else
		userInfo.mailMgr:addNew(1, subject, content)
	end
end

function mailsys.sendStandard(uid, mailType)
	local userInfo = UserInfo.GetUserInfoById(uid)

	if userInfo == nil then
		local mail = create(0, mailType)
		save(uid, mail)
	else
		userInfo.mailMgr:addNew(mailType)
	end
end

function mailsys.save(uid, mail)
	local data = unilight.getdata("mail", uid)
	
	if data == nil then 
		unilight.debug("Can not get mail about uid:" .. uid)

		data = {
			uid = uid,
			id = 0,
			mails = {}
		}
	end

	if data.mails == nil then
		unilight.debug("mail is nil, UID:" .. uid)
		data.mails = {}
	end

	if #data.mails == MAIL_MAX then
		table.remove(data.mails, 1)
	end

	data.id = data.id + 1
	mail.id = data.id
	table.insert(data.mails, mail)

	unilight.savedata(MAIL_DB, data)
end
