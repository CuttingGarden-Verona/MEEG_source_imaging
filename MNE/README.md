# EEG source reconstruction: inverse methods and regularization

Material for the hands-on session on **source reconstruction**, built on top of the
[MNE-Python](https://mne.tools/stable/index.html) material of PracticalMEEG (dataset `ds000117`, subject `sub-01`).

Everything upstream of the inverse problem has already been computed and is
distributed with this folder. The session is entirely about what happens **after**
the forward model: choosing an inverse method, choosing a regularization level, and
seeing how much of the resulting cortical map depends on those choices.

**Modality: EEG only.** The MEG channels of the dataset are not used.

---

## What we will do

The inverse problem is ill-posed: there are far more candidate sources than sensors,
so infinitely many source distributions explain the same data equally well. Every
reconstruction algorithm resolves that ambiguity by adding assumptions. The aim of
this session is not to obtain "the correct picture of the brain", but to see what
those assumptions do to the picture, and to learn which parameters must be reported
for a result to be reproducible.

By the end of the session you should be able to:

1. tell the forward and the inverse problem apart, and say why the latter is ill-posed;
2. build an inverse operator from an evoked response, a noise covariance and a
   forward solution;
3. apply and compare **MNE**, **dSPM** and **sLORETA** on the same data;
4. explain what λ² = 1/SNR² does, and predict the effect of changing it;
5. extract and interpret time courses in anatomical **ROIs**;
6. display reconstructed activity on the cortical surface and drive the 3D viewer;
7. reproduce the whole analysis from the distributed files and the documented parameters.

### The three conditions

Epochs were averaged separately into three conditions. **No contrast is computed**:
each condition is reconstructed on its own.

| condition | triggers | description |
|---|---|---|
| `famous` | 5, 6, 7 | famous faces |
| `unfamiliar` | 13, 14, 15 | unfamiliar faces |
| `scrambled` | 17, 18, 19 | scrambled faces |

---

## Before the session

1. Download this folder and unzip it wherever you like. Keep its internal structure
   intact: the notebooks find the data through relative paths.
2. Install **MNE-Python 1.10 or later**, as a *full install* with all dependencies —
   **not** "MNE-Python with core functionalities only". Instructions:
   https://mne.tools/stable/install/index.html
3. Install the two extra packages that are not part of the MNE install:
   `pandas` and `ipywidgets` (see the table below).
4. Check your installation by running the cell shown in *Check your setup*, further down.

You do **not** need to download `ds000117` or FreeSurfer: everything needed is
already in `data/` and `subjects/`.


### Start a Jupyter notebook

Open a terminal, activate the Python environment in which you installed MNE-Python
(how you do this depends on how you installed it — see the MNE installation
instructions). Then navigate with `cd` to this folder and run:

```
jupyter lab
```

Jupyter opens in your browser: go into `notebooks/` and click the notebook you want
to run.

---

## Program of the session

| | |
|---|---|
| Lecture | Source-level analysis: forward and inverse problem, source space, BEM, lead field, noise covariance, regularization, minimum-norm family |
| Hands-on part 1 | [`01_inverse_solutions.ipynb`](notebooks/01_inverse_solutions.ipynb) — from evoked responses to source estimates |
| Hands-on part 2 | [`02_visualization.ipynb`](notebooks/02_visualization.ipynb) — comparing what the choices produced |
| Discussion | which map is "the right one"? what has to go in the methods section? |

### Notebook 1 — `01_inverse_solutions.ipynb`

0. Setup
1. Loading the prepared data
2. The three evoked responses (all three in one plot, then one at a time)
3. The inverse operator (`loose`, `depth`)
4. A first solution: dSPM with SNR = 3, displayed on the cortex
5. Regions of interest: `aparc` parcellation, `mean_flip` extraction
6. The grid: 3 methods × 4 SNR values × 3 conditions, saved to disk
7. Wrap-up
8. **Your turn** — you choose condition, method and SNR, first by filling in blanks
   in the code, then with menus and sliders

### Notebook 2 — `02_visualization.ipynb`

0. Setup
1. Interactive exploration: rotate the brain, move through time, overlay `aparc`,
   link two windows together
2. Cortical maps: same instant, different methods
3. Cortical maps: same method, different regularization
4. ROI time courses across methods, SNR values and conditions
5. Peaks: latency, hemisphere, MNI coordinates
6. Spatial extent of the solution, as a number
7. **Your turn** — build your own comparison figure, then browse the whole grid with
   sliders and open any combination in the 3D viewer

---

## Folder structure

```
.
├── README.md
├── data/                           inputs, ready to use
│   ├── sub-01-eeg-ave.fif          three evoked responses (famous, unfamiliar, scrambled)
│   ├── sub-01-eeg-cov.fif          noise covariance
│   ├── sub-01-eeg-fwd.fif          EEG forward solution (lead field)
│   ├── sub-01-src.fif              source space
│   ├── sub-01-trans.fif            head ↔ MRI transformation
│   ├── sub-01-eeg-epo.fif          EEG epochs (optional, for extensions)
│   └── provenance.json             parameters, software versions, SHA-256 checksums
│
├── subjects/                       FreeSurfer anatomy (SUBJECTS_DIR)
│   └── sub-01/{bem, surf, label, mri}
│
├── notebooks/
│   ├── 01_inverse_solutions.ipynb
│   └── 02_visualization.ipynb
│
└── results/                        created by the notebooks, empty at the start
    ├── sub-01-eeg-inv.fif          the inverse operator you used
    ├── stc/                        source estimates, ~5 MB each
    ├── summary_peaks.csv           peak of every solution, with MNI coordinates
    ├── roi_timecourses.csv         ROI time courses for the whole grid
    └── figures/                    figures produced by the notebooks
```

`results/` is fully regenerable: delete it and rerun the notebooks if anything goes
wrong.

---

## The data

### `sub-01-eeg-ave.fif` — evoked responses

Three `Evoked` objects in one file, one per condition, already averaged. Read one at
a time:

```python
evoked = mne.read_evokeds("data/sub-01-eeg-ave.fif", condition="famous", proj=True)
```

−0.2 … +0.8 s around stimulus onset, 300 Hz, ~70 EEG channels. `proj=True` applies
the average-reference projector, which MNE-Python requires for EEG modelling.

Preprocessing already applied:

- channels retyped: EEG061 and EEG062 → EOG, EEG063 → ECG, EEG064 → misc
  (unconnected electrode); these are then excluded;
- average reference;
- resampling to 300 Hz;
- 1–40 Hz FIR band-pass;
- epochs −0.5 … +2.0 s, baseline −0.2 … 0 s;
- projector-delay correction: +34 ms;
- ocular and cardiac artifacts removed with **ICA**.

### `sub-01-eeg-cov.fif` — noise covariance

Estimated on the pre-stimulus window (−0.25 … 0 s) across all epochs, `empirical`
method, `rank="info"`. It describes how much noise there is on each sensor and how
the noise is correlated across sensors, and is used to whiten the data before
inversion. Its rank is lower than the number of channels, because the average
reference removes one degree of freedom.

### `sub-01-eeg-fwd.fif` — forward solution

The lead field: how each cortical source would project onto the electrodes.

- **three-layer BEM** (brain, skull, scalp), conductivities (0.3, 0.006, 0.3) S/m —
  three layers are indispensable for EEG, whereas MEG would only need the inner one;
- `oct5` surface source space, ~8200 sources (~4100 per hemisphere);
- `mindist = 5 mm`;
- coregistration from `sub-01-trans.fif`;
- surface orientation with cortical patch statistics.

Technical note: `ico=5` produces a BEM too dense to save in FIF format (overflow
error). `ico=4` is sufficient for a three-layer BEM, as MNE itself recommends.

### `sub-01-src.fif`, `sub-01-trans.fif`, `sub-01-eeg-epo.fif`

The source space and the head ↔ MRI transformation are already contained in the
forward solution; they are distributed for reproducibility and for anyone who wants
to recompute the forward model. The single-trial epochs are not needed by
minimum-norm methods — they are there for anyone who wants to try an LCMV beamformer
or a trial-level analysis.

### `subjects/sub-01/`

FreeSurfer reconstruction: cortical surfaces for plotting (`surf/`), the `aparc`
atlas for the ROIs (`label/`), head surfaces (`bem/`), T1 and transformations for MNI
coordinates (`mri/`).

### `data/provenance.json`

All parameters, software versions and SHA-256 checksums of the distributed files.
This is the file to open when you wonder "which settings produced this?".

---

## Required packages

Everything below except `pandas` and `ipywidgets` comes with a *full* MNE-Python
install.

| package | version | used for |
|---|---|---|
| `python` | ≥ 3.10 (tested on 3.11) | — |
| `mne` | **≥ 1.10** (tested on 1.12.1) | the whole analysis |
| `numpy` | ≥ 1.24 | numerics |
| `scipy` | ≥ 1.10 | numerics |
| `matplotlib` | ≥ 3.7 | 2D figures |
| `pandas` | ≥ 2.0 | result tables and CSV files |
| `ipywidgets` | ≥ 8.0 | the menus and sliders in the "Your turn" sections |
| `pyvista` | ≥ 0.43 | 3D cortical rendering |
| `pyvistaqt` | ≥ 0.11 | interactive 3D windows |
| `PyQt5` or `PySide6` | — | Qt backend |
| `nibabel` | ≥ 5.0 | reading FreeSurfer files |
| `jupyterlab` | — | running the notebooks |

Optional:

- `trame`, `trame-vtk`, `trame-vuetify` — only if you want the 3D brain **inside**
  the notebook (`mne.viz.set_3d_backend("notebook")`). Without them the notebooks use
  `pyvistaqt`, which opens a separate window: that is the default and works fine.
- `scikit-learn` — alternative covariance estimators (`shrunk`, `ledoit_wolf`).
- `nilearn` — anatomical MRI display.

Installing the two extras:

```
conda install -c conda-forge pandas ipywidgets
```

or, with pip:

```
pip install pandas ipywidgets
```

### Check your setup

Run this in a notebook cell. No error should appear, and the MNE version should be
1.10 or higher:

```python
import mne, numpy, scipy, matplotlib, pandas, ipywidgets, pyvista, pyvistaqt, nibabel
print("MNE-Python:", mne.__version__)
mne.viz.set_3d_backend("pyvistaqt")
print("3D backend:", mne.viz.get_3d_backend())
mne.sys_info()
```

Then check that the data is where the notebooks expect it:

```python
from pathlib import Path
for f in ["data/sub-01-eeg-ave.fif", "data/sub-01-eeg-cov.fif",
          "data/sub-01-eeg-fwd.fif", "subjects/sub-01/surf/lh.inflated",
          "subjects/sub-01/label/lh.aparc.annot"]:
    print(Path(f).exists(), f)
```

---

## References and credit

**Dataset**

	Wakeman, D. G., & Henson, R. N. 2015. A multi-subject, multi-modal human
	neuroimaging dataset. Scientific Data, 2, 150001.

**Original teaching material**

This session is built on the MNE-Python notebooks of PracticalMEEG 2025 by
N. Schaworonkow, S. Kern, M. van Vliet, B. Westner, A. Gramfort and D. A. Engemann:
https://github.com/wmvanvliet/mne_practical_meeg_2025

Those notebooks are in turn inspired by:

	Mainak Jas, Eric Larson, Denis Engemann, Jaakko Leppakangas, Samu Taulu,
	Matti Hamalainen, and Alexandre Gramfort. 2018. A Reproducible MEG/EEG Group
	Study With the MNE Software: Recommendations, Quality Assessments, and Good
	Practices. Frontiers in Neuroscience. 12, doi: 10.3389/fnins.2018.00530
