
# Synchronous usage
import sys
import time
from gitingest import ingest

url = sys.argv[1]

summary, tree, content = ingest(url)
# print(summary)
# print(tree)
print(content)
