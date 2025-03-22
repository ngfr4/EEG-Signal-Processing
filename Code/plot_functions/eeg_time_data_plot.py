import os

import numpy as np
from scipy.io import loadmat
import matplotlib.pyplot as plt

condition = "cognitive_task"  # resting_state, cognitive_task
subject = "Subject01"
condition_idx = 1 if condition == "resting_state" else 2
Fs = 500

folder_path = os.path.dirname(os.path.abspath(__file__))
eeg_data = loadmat(os.path.join(folder_path, f"{subject}_{condition_idx}.mat"))
eeg_data.pop("__header__")
eeg_data.pop("__version__")
eeg_data.pop("__globals__")

eeg_data_tuple = eeg_data.items()
labels = [channel_name for channel_name, _ in eeg_data_tuple]
eeg_data_array = np.stack([channel_data for _, channel_data in eeg_data_tuple])

bottom = np.amin(eeg_data_array[0:eeg_data_array.shape[0]])
top = np.amax(eeg_data_array[0:eeg_data_array.shape[0]])
if condition == "resting_state":
    fig = plt.figure(figsize=(12, 8))
else:
    fig = plt.figure(figsize=(4, 8))
ax0 = fig.add_subplot(111)
plt.subplots_adjust(hspace=-0.5)
ax0.tick_params(labelcolor='black', top=False,
                bottom=False, left=False, right=False)
for idx in range(0, eeg_data_array.shape[0]):
    if idx == 0:
        _ax = fig.add_subplot(eeg_data_array.shape[0], 1, idx+1)
        ax = _ax
    else:
        ax = fig.add_subplot(eeg_data_array.shape[0], 1, idx+1, sharex=_ax)
    if idx == eeg_data_array.shape[0]-1:
        ax.tick_params(labelcolor='black', top=False,
                       bottom=True, left=False, right=False)
        ax.patch.set_alpha(0)
        ax.get_yaxis().set_visible(False)
        ax.spines['top'].set_visible(False)
        ax.set_xlabel('Time (sec)')
    else:
        ax.axis('off')

    # Plot EEG data (without the last 2 seconds - faulty data)
    if condition == "resting_state":
        time = np.arange(0, len(eeg_data_array[idx, :180*Fs])*1/Fs, 1/Fs)
        ax.plot(time, eeg_data_array[idx, :180*Fs],  linewidth=0.5)
    else:
        time = np.arange(0, len(eeg_data_array[idx, :60*Fs])*1/Fs, 1/Fs)
        ax.plot(time, eeg_data_array[idx, :60*Fs],  linewidth=0.5)
    ax.set_ylim(bottom, top)
    plt.text(-0.45, 0, labels[idx-1])

ax0.get_yaxis().set_visible(False)
ax0.get_xaxis().set_visible(False)
plt.savefig(os.path.join(folder_path, "Figures",
            f"{condition}_eeg.png"), dpi=600)
plt.show()
