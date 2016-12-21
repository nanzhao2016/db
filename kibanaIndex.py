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
import glob
import subprocess


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
		if len(args) > 1:
			# Select files to process
			print("Processing command line args as files (absolute path):")
			args = args[1:]
			files = [os.path.join('', f) for f in args]
			#print(files)
		else:
			# Select all JSON in path and subdirs
			print("Searching for files in: " + path)
			files=[]
			for f in glob.glob(ps.path.join(path, '*.json')):
				files.append(f)
			
		print("Files found:")
		for f in files:
			print(f)
		
		print("Found {} files. Transfer to ES? [y/N]: ".format(str(len(files))))
		ans = sys.stdin.readline()
		# bulk api
		if ans[0] == 'y':
			for f in files:
				print(">>> Processing file : " + f)
				cat = subprocess.Popen(["cat", f], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
				std_out, std_err = cat.communicate(str.encode('utf-8'))
				lines = std_out.decode('utf-8').splitlines()
				bulk(client=self.es, actions=lines, stats_only=True, index=joblisting_index, doc_type=doc_type)
		
		
		#elasticsearch index
		"""
		i=0
		if ans[0] == 'y':
			for f in files:
				print(">>> Processing file : " + f)
				with open(f, encoding='utf-8') as jsFile:
					while True:
						line = jsFile.readline()
						if not line:
							break
						else:
							#bulk(client=self.es, actions=json.loads(line), stats_only=True, index=joblisting_index, doc_type=doc_type)
							try:
								print(i)
								i = i+1
								self.es.index(joblisting_index, doc_type, line, id=i)
							
							except Exception:
									print(i-1)
									print(line)
									break		
		"""
		else:
			print("Exiting")
			exit()
			
			
def main(avgs):
	"""
	es_host = "127.0.0.1"
	es_host = "10.170.19.5"
	es_port = "9200"
	"""
	joblisting_index = 'velib'
	doc_type = 'velib'
	mapping_file = 'C:/Users/OPEN/Documents/NanZHAO/Formation_BigData/Memoires/tmp/db/velib_es_mapping.json'
	path_dir = "station_json/"
	connecter = ElasticsearchConnector("127.0.0.1", "9200")
	#connecter = ElasticsearchConnector("10.170.19.5", "9200")
	connecter.getNodes()
	connecter.createIndex(joblisting_index, doc_type, mapping_file)
	connecter.loadDatatoEs(avgs, path_dir, joblisting_index, doc_type)
	
if __name__ == "__main__": 
	main(sys.argv)
	
