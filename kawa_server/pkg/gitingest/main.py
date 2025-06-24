
# Synchronous usage
import sys
from gitingest import ingest  # type: ignore

url = sys.argv[1]

summary, tree, content = ingest(url)
# print(summary)
# print(tree)
print(content)
