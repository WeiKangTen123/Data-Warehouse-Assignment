import matplotlib.pyplot as plt
import pandas as pd

# Create data for plotting based on the user's output
data = {
    'Year': ['2014'] * 12 + ['2015'] * 12,
    'Quarter': ['Q1', 'Q1', 'Q1', 'Q2', 'Q2', 'Q2', 'Q3', 'Q3', 'Q3', 'Q4', 'Q4', 'Q4'] * 2,
    'Platform': ['SHOPEEFOOD', 'GRAB', 'FOODPANDA'] * 4 * 2,
    'Revenue': [
        732882.85, 727519.45, 724086.80, 736556.75, 730416.90, 727585.50, 
        751701.60, 746508.25, 738421.65, 750416.25, 740852.05, 735637.95,
        730128.45, 727658.60, 721116.30, 747725.05, 744601.05, 733614.30, 
        752201.40, 747576.05, 746224.80, 732937.15, 732130.60, 726274.90
    ]
}

# Convert the data into a pandas DataFrame
df = pd.DataFrame(data)

# Plotting
plt.figure(figsize=(10, 6))

# Group data by Platform and plot each one
for platform, group in df.groupby('Platform'):
    plt.plot(group['Quarter'] + ' ' + group['Year'], group['Revenue'], label=platform, marker='o')

plt.title('Platform Sales Comparison (2014-2015)')
plt.xlabel('Quarter and Year')
plt.ylabel('Revenue (RM)')
plt.xticks(rotation=45)
plt.legend(title="Platform")
plt.tight_layout()

# Show the plot
plt.show()
