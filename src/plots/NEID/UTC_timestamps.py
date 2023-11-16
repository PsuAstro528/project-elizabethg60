import pandas as pd
from datetime import datetime

"""
return UTC timestamps of NEID data to be used in MyProject
"""

data = pd.read_csv("NEID_Data.csv")
UTC_time = []
for i in data["obsdate"][15:-150]:
    UTC_time.append(datetime.strptime(i, "%Y-%m-%d %H:%M:%S").strftime("%Y-%m-%dT%H:%M:%S"))

print(UTC_time)