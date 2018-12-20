#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os
import sys

def docmd(cmd):
    print(cmd)
    assert(os.system(cmd)==0)

def init(outdir, gitlab):
    if not os.path.isdir(outdir):
        cmd = "git clone %s %s"%(gitlab, outdir)
        docmd(cmd)
    else:
        cmd = "cd %s && git pull && cd -"%outdir
        docmd(cmd)

def push(outdir, commit):
    cmd = "cd %s && git add . && git commit -m '%s' && git push && cd -"%(outdir, commit)
    docmd(cmd)

def checkOrMake(dirname):
    if not os.path.isdir(dirname):
        os.makedirs(dirname)

def walkExec(outdir, gitlab, fileext, execfmt, *projects):
    init(outdir, gitlab)

    projects = list(set(projects))
    if len(projects) == 0:
        projects = ["."]

    for p in projects:
        for root, dirs, files in os.walk(p):
            if outdir in root or ".git" in root:
                continue
            newdir = os.path.abspath(os.path.join(outdir, root))
            checkOrMake(newdir)
            for f in files:
                if os.path.splitext(f)[1] != fileext:
                    continue
                absname = os.path.join(root, f)
                newname = os.path.join(newdir, f)
                execstr = execfmt%(newname, absname)
                print(execstr)
                assert(os.system(execstr)==0)

    push(outdir, "autocommit")

def main():
    outdir = ".gxlua_enc"
    gitlab = "git@git.code4.in:LuaLibraryEnc/gxlua_enc.git"
    fileext = ".lua"
    execfmt = "luac -o %s %s"
    walkExec(outdir, gitlab, fileext, execfmt, *(list(sys.argv[1:])))

if __name__=='__main__':
    main()


