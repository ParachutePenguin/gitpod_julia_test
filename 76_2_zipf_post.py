import pandas as pd
import matplotlib.pyplot as plt

# StanのFitオブジェクトからDataFrameを作成
df = fit.to_frame()

# DataFrameからパラメータのプロットを作成
plt.figure(figsize=(10, 4))
df['alpha'].plot(kind='hist', bins=50)
plt.title('Alpha Parameter Distribution')
plt.xlabel('Alpha')
plt.ylabel('Frequency')
plt.show()
