#!/usr/bin/python

import sys
import subprocess

def main(argc, argv):
	target = argv[1]
	label = argv[2]
	revision = argv[3]
	
	sed_str = '\'/^XBCS-LABEL/{h;s/=.*/: SHA/};${x;/^$/{s//XBCS-LABEL: SHA/;H};x}\''
	sed_str = sed_str.replace('LABEL', label).replace('SHA', revision)
	sed_str = 'sed -i ' + sed_str + ' ' + target
	
	print(sed_str)

	p = subprocess.Popen(sed_str, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

if __name__ == "__main__":
	main(len(sys.argv), sys.argv)
