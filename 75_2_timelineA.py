# Corrected Python code for plotting commit data with seaborn and matplotlib

import matplotlib.pyplot as plt
from matplotlib.ticker import LogLocator, LogFormatter
import pandas as pd
import seaborn as sns
import os
from pathlib import Path

# This is a placeholder for the actual data loading logic
df = pd.read_csv('tensorflow_commits.csv') 
# The data frame `df` would be created from the actual data, here we simulate it
# Let's assume `df` has columns 'date' for commit dates and 'committer' for committer names

# A function to plot commit data
def plot_commit_data(df, freq='M', output_folder='003_output'):
    # Ensure the output directory exists
    Path(output_folder).mkdir(parents=True, exist_ok=True)

    # Convert commit dates to datetime
    df['date'] = pd.to_datetime(df['date'])

    # Define periods based on frequency
    if freq == 'A':
        periods = ['ALL']
        # For 'ALL', we don't need to create a 'period' column
        commit_counts = df.groupby('committer').size().reset_index(name='commit_count')
    else:
        if freq == 'Q':
            df['period'] = df['date'].dt.to_period('Q')
            periods = df['date'].dt.to_period('Q').dt.strftime('Q%q-%Y').unique()
        elif freq == 'M':
            df['period'] = df['date'].dt.to_period('M')
            periods = df['date'].dt.to_period('M').dt.strftime('%b-%Y').unique()
        
        # Group by committer and period
        commit_counts = df.groupby(['committer', 'period']).size().reset_index(name='commit_count')
    
    commit_counts = commit_counts.sort_values(by='commit_count', ascending=False)
    # The rest of the code remains the same

    # Plot for all data combined if 'ALL' selected, else plot for each period
    if freq == 'A':
        plt.figure(figsize=(10, 6))
        scatter = sns.scatterplot(x='committer', y='commit_count', data=commit_counts)
        scatter.set(yscale="log", xscale="log")
        # Define the log format
        plt.gca().yaxis.set_major_locator(LogLocator(base=10))
        plt.gca().yaxis.set_major_formatter(LogFormatter(base=10))
        plt.gca().xaxis.set_major_locator(LogLocator(base=10))
        plt.gca().xaxis.set_major_formatter(LogFormatter(base=10))

        plt.xticks(rotation=90)
        plt.title('Total Commits by committer (All Time)')
        plt.xlabel('Committer')
        plt.ylabel('Commit Count (Log scale)')

        # Save the combined plot
        plt.savefig(f"{output_folder}/{freq}_all_time.png")
        plt.close()
    elif freq == 'Q':
        df['period'] = df['date'].dt.to_period('Q')
        periods = df['date'].dt.to_period('Q').dt.strftime('Q%q-%Y').unique()
    else:
        # Default to monthly if not quarterly
        df['period'] = df['date'].dt.to_period('M')
        periods = df['date'].dt.to_period('M').dt.strftime('%b-%Y').unique()

    # Aggregate commit counts
    commit_counts = df.groupby(['committer', 'period']).size().reset_index(name='commit_count')
    commit_counts = commit_counts.sort_values(by='commit_count', ascending=False)

    # Plot for all data combined
    plt.figure(figsize=(10, 6))
    scatter = sns.scatterplot(x='committer', y='commit_count', data=commit_counts)
    #scatter.set(yscale="log", xscale="log")あ
    # Set log scale with base 10
    plt.yscale('log', base=10)
    plt.xscale('log', base=10)

    # Define the log format
    plt.gca().yaxis.set_major_locator(LogLocator(base=10))
    plt.gca().yaxis.set_major_formatter(LogFormatter(base=10))
    plt.gca().xaxis.set_major_locator(LogLocator(base=10))
    plt.gca().xaxis.set_major_formatter(LogFormatter(base=10))

    plt.xticks(rotation=90)
    plt.title('Total Commits by committer')
    plt.xlabel('Committer')
    plt.ylabel('Commit Count (Log scale)')

    # Save the combined plot
    plt.savefig(f"{output_folder}/{freq}_0.png")
    plt.close()

    # Plot for each period
    for i, period in enumerate(periods):
        # Filter data for the period
        period_data = commit_counts[commit_counts['period'].dt.strftime('Q%q-%Y') == period] if freq == 'Q' else \
                      commit_counts[commit_counts['period'].dt.strftime('%b-%Y') == period]
        
        # Plotting
        plt.figure(figsize=(10, 6))
        scatter = sns.scatterplot(x='committer', y='commit_count', data=period_data)
        scatter.set(yscale="log", xscale="log")
        # Set log scale with base 10
        plt.yscale('log', base=10)
        plt.xscale('log', base=10)

        # Define the log format
        plt.gca().yaxis.set_major_locator(LogLocator(base=10))
        plt.gca().yaxis.set_major_formatter(LogFormatter(base=10))
        plt.gca().xaxis.set_major_locator(LogLocator(base=10))
        plt.gca().xaxis.set_major_formatter(LogFormatter(base=10))

        plt.xticks(rotation=90)
        plt.title(f'Commits by committer for {period}')
        plt.xlabel('Committer')
        plt.ylabel('Commit Count (Log scale)')
        
        # Save plot
        plt.savefig(f"{output_folder}/{freq}_{i+1}.png")
        plt.close()


# Example usage:
plot_commit_data(df, freq='A', output_folder='003_2_output2')

# Note: Actual data loading and function call should be done in the user's environment, not here.

