#! /usr/bin/python3
import re
import sys
import getopt
import subprocess
import os
import shutil
import hashlib
import datetime

class Error(Exception):
    """Base class for exceptions in this module."""
    pass
 
class InputError(Error):
    """Exception raised for errors in the input.
 
    Attributes:
        expression -- input expression in which the error occurred
        message -- explanation of the error
    """
    def __init__(self, message):
        self.message = "Error: %s" % message
		
# 修改版本号
def modifierVsesion(fileName,version,regular="s.version\s*=\s*'(.*?)'"):

	print("******************正在修改'%s'版本号为'%s'" % (fileName, version))
	try:
		f = open(fileName,'r+')
	except Exception as e:
		raise InputError("'%s'打开出错" % fileName)
	
	readlines = f.readlines()
	f.close()
	data = ''
	line = -1
	for index, lineStr in enumerate(readlines):
	    # re.findall() 返回的是一个列表，无匹配元素时，返回的是空列表
	    find = re.findall(regular,lineStr)
	    # 判断列表是否为空
	    if find:
	        # 列表不为空时取列表中的第一个元素
	        oldVersion = str(find[0])
	        line = index
	        data = re.sub(oldVersion, version, lineStr)
	        break
	    else:
	        continue
	

	if len(data) == 0 or line == -1:
		raise InputError("'%s'中的未匹配到内容" % fileName)

	readlines[line] = data
	output = open(fileName,'w')
	output.writelines(readlines)
	output.close()
	print("******************结束******************")

# 执行命令行命令
def executiveCommand(command, isSystem = False):
	print("******************正在执行命令:'%s'" % command)
	if isSystem == True:
		os.system(command)
	else:
		process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		process.wait()
		command_output = process.stdout.read().decode('utf-8')
		print(command_output)
	print("******************结束******************")


def main(argv):
	version = ''
	message = ''
	try:
		opts, args = getopt.getopt(argv, "hv:m:", ["version=","message="])
	except getopt.GetoptError:
		print("build.py -v <version> -m <message>")
		sys.exit(2)
	for opt, arg in opts:
		if opt == "-h":
			print("build.py -v <version> -m <message>")
			sys.exit(2)
		elif opt in ("-v", "--version"):
			version = arg
		elif opt in ("-m", "--message"):
			message = arg

	if len(version) == 0:
		print("build.py -v <version> -m <message>")
		sys.exit(2)
		
	try:
		# 1.修改版本号
		modifierVsesion("MAExtension.podspec", version)

		# 3.提交本地git
		executiveCommand('git add .')
		showMessage = "V%s %s" % (version, message)
		executiveCommand('git commit -m "%s"' % showMessage)
		executiveCommand('git tag %s -m "%s" -f' % (version, showMessage))
		executiveCommand('git push origin :refs/tags/%s' % version)
		executiveCommand('git push origin master')
		executiveCommand('git push --tags')
	except Exception as e:
		print(e)
		exit()


if __name__=="__main__":
    main(sys.argv[1:])
