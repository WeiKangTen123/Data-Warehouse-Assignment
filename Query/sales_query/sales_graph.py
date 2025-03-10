import matplotlib.pyplot as plt

# Data from the image
quarters = ['Q1', 'Q2', 'Q3', 'Q4']

# Sales data for 2014 and 2015
sales_2014 = [5452033.80, 5489856.95, 5596077.20, 5564750.75]
sales_2015 = [5420402.30, 5545773.50, 5601442.75, 5587373.15]

# Growth percentages for 2014 and 2015 (as floats for plotting)
growth_2014 = [None, 0.69, 1.93, -0.56]
growth_2015 = [None, 2.31, 1.00, -0.25]

# Create figure and axes for plotting
fig, ax1 = plt.subplots(figsize=(10, 6))

# Plot sales data
ax1.plot(quarters, sales_2014, label='Sales 2014', marker='o', color='b')
ax1.plot(quarters, sales_2015, label='Sales 2015', marker='o', color='g')

# Labels and title for the sales data
ax1.set_xlabel('Quarter')
ax1.set_ylabel('Sales (in millions)', color='black')
ax1.set_title('Quarterly Sales Comparison: 2014 vs 2015')
ax1.legend(loc='upper left')

# Create a secondary axis for the growth percentages
ax2 = ax1.twinx()
ax2.plot(quarters, growth_2014, label='Growth % 2014', marker='x', linestyle='--', color='blue')
ax2.plot(quarters, growth_2015, label='Growth % 2015', marker='x', linestyle='--', color='green')

# Labels and title for the growth data
ax2.set_ylabel('Growth %', color='black')
ax2.legend(loc='upper right')

# Display the graph
plt.tight_layout()
plt.show()
