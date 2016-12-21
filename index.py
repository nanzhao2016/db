#!/usr/bin/env
# -*- coding: utf-8 -*

"""
###########################################
#####       EXPORTATION ANNONCES      #####
###########################################
"""


################################################################
##                                                            ##        
##                     LIBRAIRIES                             ##
##                                                            ##
################################################################

from elasticsearch.client import Elasticsearch
from elasticsearch.helpers import bulk
import requests
import json
import sys
import os
import fnmatch
import subprocess
import sh

class ElasticsearchConnector(object):
	def __init__(self, hostName, postNum):
		self.host = hostName
		self.post = postNum
		if (requests.get('http://' + self.host + ':' + self.post).content):
			# Connect to cluster
			self.es = Elasticsearch([{'host': self.host, 'port': self.post}])
		else:
			print("Please turn on elasticsearch")
			
	def connet(self):
		return(self.es)

	def getNodes(self):
		# Print ES node information
		nodes = self.es.cat.nodes()
		print(">>> Elasticsearch Node information :")
		print("---")
		print(nodes)
		print("---")
		
	def createIndex(self, joblisting_index, doc_type, mapping_file):
		# Delete index if exists
		if self.es.indices.exists(joblisting_index):
			print("Index " + joblisting_index + " already existed. Delete? [y/N]")
			ans = sys.stdin.readline()
			if ans[0].lower() == 'y':
				self.es.indices.delete(index=joblisting_index)
		# Create index
		print("Creating Index " + joblisting_index)
		self.es.indices.create(index=joblisting_index, ignore=400)
		try:
			#fname = doc_type + "_mapping.json"
			#fname = mapping_file
			print("Using file {} to define mapping".format(mapping_file))
			with open(mapping_file) as fm:
				mapping = json.load(fm)
				self.es.indices.put_mapping(index=joblisting_index, doc_type=doc_type, body=mapping)

		except IOError:
			print("Didn't find mapping file. Creating index without mapping.")
	
	def loadDatatoEs(self, args, path, joblisting_index, doc_type):
	
		files = getFilelist(path)
		print("Found {} files. Transfer to ES? [y/N]: ".format(str(len(files))))
		ans = sys.stdin.readline()
		if ans[0] == 'y':
			for f in files:
				print(">>> Processing file : " + f)
				cat = subprocess.Popen(["hadoop", "fs", "-cat", f], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
				std_out, std_err = cat.communicate(str.encode('utf-8'))
				lines = std_out.decode('utf-8').splitlines()
				type(lines)
				bulk(client=self.es, actions=lines, stats_only=True, index=joblisting_index, doc_type=doc_type)
				
def getFilelist(path_hdfs):
	files=[]
	commands = sh.hdfs('dfs', '-ls', path_hdfs).split('\n')
	for c in commands[1: len(commands)-1]:
		files.append(c.rsplit(None,1)[-1])
	
	print("Files found:")
	for f in files:
		print(f)

	return (files)	
			
def main(avgs):
	"""
	es_host = "127.0.0.1"
	es_host = "10.170.19.5"
	es_port = "9200"
	"""
	joblisting_index = 'velib'
	doc_type = 'velib'
	mapping_file = 'velib_es_mapping.json'
	path_hdfs = "/tmp/bikes2/"
	#connecter = ElasticsearchConnector("127.0.0.1", "9200")
	connecter = ElasticsearchConnector("10.170.19.5", "9200")
	connecter.getNodes()
	connecter.createIndex(joblisting_index, doc_type, mapping_file)
	connecter.loadDatatoEs(avgs, path_hdfs, joblisting_index, doc_type)
	
if __name__ == "__main__": 
	main(sys.argv)
	
