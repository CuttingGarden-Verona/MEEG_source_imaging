# EEG Source Imaging with Brainstorm

**Student tutorial · guided source reconstruction and reproducibility exercise**

This hands-on is part of the **Open Science Day** of CuttingGardens 2026 – Verona.

> **Scope**  
> The introductory lecture discusses both EEG and MEG source imaging.  
> In this practical session, however, **all source reconstructions are performed using EEG only**.  
> MEG is mentioned for context and for comparison with the broader M/EEG framework.

---

## Learning goals

By the end of the hands-on, you should be able to:

- load a prepared Brainstorm protocol;
- identify the main ingredients required for source reconstruction:
  - evoked responses,
  - EEG sensor geometry,
  - cortical source space,
  - forward model,
  - noise covariance;
- compute cortical EEG source estimates using minimum-norm imaging;
- compare different inverse-map variants:
  - **MNE**,
  - **dSPM**,
  - **sLORETA**;
- explore the effect of regularization by changing the assumed **SNR**;
- inspect source activity around the EEG **N170** response;
- extract source time series from predefined visual ROIs;
- compare the conclusions obtained with Brainstorm with those obtained by the group working with **MNE-Python**.

---

# Dataset and teaching material

We use the **Wakeman & Henson multimodal face-processing dataset**.

For this practical we focus on:

- subject: **sub-01**
- run: **Run 01**
- modality: **EEG**
- conditions:
  - **Famous**
  - **Unfamiliar**
  - **Scrambled**

Useful resources:

- [Wakeman & Henson dataset paper](https://www.nature.com/articles/sdata20151)
- [From raw MEG/EEG to publication: How to perform MEG/EEG group analysis with free academic software](https://www.frontiersin.org/research-topics/5158/from-raw-megeeg-to-publication-how-to-perform-megeeg-group-analysis-with-free-academic-software/magazine)
- [PracticalMEEG 2025 Brainstorm materials](https://zenodo.org/records/17644377)
- [PracticalMEEG 2025 MNE-Python materials](https://zenodo.org/records/18359739)

For this hands-on, download the prepared Brainstorm protocol:

➡️ [PracticalMEEG_Single_Precomputed.zip](https://zenodo.org/records/17644377/files/PracticalMEEG_Single_Precomputed.zip?download=1)

---

# 1. Install Brainstorm

Brainstorm can be run:

- from **MATLAB**, or
- as a **standalone compiled application**.

Please install and test Brainstorm **before the hands-on**.

Official instructions:

➡️ [Brainstorm installation guide](https://neuroimage.usc.edu/brainstorm/Installation)

### MATLAB version

1. Download Brainstorm.
2. Unzip the Brainstorm distribution.
3. Start MATLAB.
4. Change the MATLAB working directory to the `brainstorm3` folder.
5. Run:

```matlab
brainstorm
```

> **Important**  
> Do not manually add the entire `brainstorm3` folder to the MATLAB path.

At first launch, Brainstorm will ask you to choose a database directory, usually called:

```text
brainstorm_db
```

Keep this database directory separate from the Brainstorm program folder.

---

# 2. Load the prepared protocol

1. Download `PracticalMEEG_Single_Precomputed.zip`.
2. Start Brainstorm.
3. Select **File → Load protocol → Load from zip file**.
4. Select `PracticalMEEG_Single_Precomputed.zip`.
5. Wait until the protocol appears in the Brainstorm database explorer.

> **If Brainstorm reports that the protocol already exists**  
> Rename the ZIP file before importing it, or detach/delete the previous copy of the protocol from the Brainstorm database.

---

# 3. Orient yourself in the protocol

In the Brainstorm database tree, locate `sub-01` and identify **Run 01**.

Before computing anything, identify the following ingredients:

- EEG averages for **Famous**, **Unfamiliar** and **Scrambled**;
- EEG channel file / sensor geometry;
- cortical anatomy and source space;
- precomputed head model;
- EEG noise covariance matrix.

The noise covariance in the original PracticalMEEG workflow is estimated from the prestimulus baseline.

### Checkpoint

Before continuing, make sure you can identify:

- the three condition averages;
- the head model;
- the noise covariance matrix.

---

# 4. From the introductory talk to the practical

The practical starts where the introductory lecture ends.

The lecture introduced:

- the ill-posed M/EEG inverse problem;
- the forward model;
- the lead-field matrix;
- minimum-norm estimation;
- regularization;
- depth weighting;
- normalized source maps such as dSPM and sLORETA.

Here we will keep the **data and forward model fixed** and explore what happens when selected choices in the inverse solution are changed.

> ## Core question
>
> **How much of a source-reconstruction result belongs to the data, and how much belongs to the choices we make when solving the inverse problem?**

---

# 5. Brainstorm source-estimation tutorial

Before starting the exercise, have a look at:

➡️ [Brainstorm Tutorial 22: Source estimation](https://neuroimage.usc.edu/brainstorm/Tutorials/SourceEstimation)

The most relevant sections are:

- Source estimation options
- Computing sources for an average
- Standardization of source maps
- Advanced options: Minimum norm

---

# 6. Define the controlled experiment

For all comparisons, keep the following choices fixed:

| Choice | Setting |
|---|---|
| Subject / run | sub-01 / Run 01 |
| Modality | EEG only |
| Conditions | Famous / Unfamiliar / Scrambled |
| Source space | cortical surface |
| Dipole orientation | constrained, normal to cortex |
| Forward model | precomputed head model |
| Noise covariance | precomputed EEG noise covariance |
| Depth weighting | unchanged |
| Other advanced options | unchanged |

We will vary only two factors:

1. **inverse-map variant**
2. **regularization level**

---

# 7. Compute a first reference solution

Start with the **Famous** condition.

### In Brainstorm

Right-click the **Famous average** and select:

```text
Compute sources [2018]
```

Use:

```text
Method:              Minimum norm imaging
Measure:             Current density map
Dipole orientations: Constrained: Normal to cortex
Sensors:             EEG
```

Then click `Show details` and check:

```text
Signal-to-noise ratio = 3
```

Leave the other advanced settings unchanged and run the computation.

### Display the source map

Right-click the new source file:

```text
Cortical activations → Display on cortex
```

Open the corresponding EEG average as a temporal reference.

Brainstorm synchronizes the sensor time series and the source map.

### First exploration

Move through approximately:

```text
50–250 ms
```

and observe how the source distribution evolves over time.

Ask yourself:

- Where does activity first appear?
- How does the spatial distribution evolve?
- What happens around 170 ms?

> **Visualization note**  
> Amplitude threshold, smoothing and colormap settings affect the display, not the underlying source time series. Keep visualization settings consistent when comparing maps.

---

# 8. Experiment A — Change the inverse method

Keep `SNR = 3` and compute the following source estimates:

| Brainstorm option | Short name | Conditions |
|---|---|---|
| Current density map | MNE | Famous / Unfamiliar / Scrambled |
| dSPM | dSPM | Famous / Unfamiliar / Scrambled |
| sLORETA | sLORETA | Famous / Unfamiliar / Scrambled |

Keep **all other parameters identical**.

### Compare the solutions

Inspect the maps, especially around the N170 time range.

Ask:

- Is the location of the strongest activity the same?
- Is the spatial extent the same?
- Are the same cortical regions emphasized?
- Is the Famous / Unfamiliar / Scrambled pattern preserved?
- Does the inverse method change the interpretation of the result?

> **Important**  
> Do **not** compare raw numerical amplitudes across MNE, dSPM and sLORETA as if they represented the same quantity.
>
> Across methods, focus on:
>
> - localization;
> - spatial pattern;
> - latency;
> - relative condition differences;
> - ROI time-course shape.

---

# 9. Experiment B — Change regularization

Now keep the inverse method fixed to **dSPM** and vary the assumed SNR.

In Brainstorm:

```text
Compute sources [2018]
→ Show details
→ Signal-to-noise ratio
```

Compute:

| Brainstorm SNR | Equivalent MNE-Python λ² |
|---:|---:|
| 1 | 1 |
| 3 | 1/9 ≈ 0.111 |
| 5 | 1/25 = 0.04 |

The relationship used in MNE-Python is:

```python
lambda2 = 1.0 / snr**2
```

Interpretation for this exercise:

- **SNR = 1** → stronger regularization
- **SNR = 3** → classical/default reference
- **SNR = 5** → weaker regularization

Repeat this for:

- Famous
- Unfamiliar
- Scrambled

Because `dSPM / SNR = 3` was already computed in Experiment A, you do not need to recompute it.

### Questions

Keeping the inverse method fixed, what changes when regularization changes?

Look at:

- peak location;
- spatial spread;
- temporal profile;
- source amplitude;
- relative condition differences.

---

# 10. Inspect the EEG N170

The face dataset shows a characteristic face-related EEG response around **170 ms**.

For EEG, we refer to this component as the **N170**. The corresponding MEG component is commonly called the **M170**.

Explore approximately:

```text
150–190 ms
```

with particular attention to ~170 ms.

For each solution, consider:

- Where is the strongest source activity?
- Does peak localization change?
- Does the map become more or less spatially extended?
- Is the face-related response robust?
- Are differences between Famous, Unfamiliar and Scrambled preserved?

A practical visualization starting point is:

```text
Smooth ≈ 30%
Amplitude threshold ≈ 20%
```

These are **display parameters only**.

> **Dataset landmark**  
> The PracticalMEEG walkthrough reports a stronger negative EEG response for Famous than Scrambled around the N170 range, with later Famous–Unfamiliar differences after approximately 250 ms. Use this as a landmark to inspect — not as a result to force.

---

# 11. Compare predefined visual ROIs

Visual comparison of cortical maps is useful but can be affected by plotting settings.

We will therefore also compare source time series extracted from predefined anatomical ROIs.

For the Brainstorm–MNE comparison, use the **same atlas-defined ROIs** in both software environments.

Suggested bilateral Desikan–Killiany parcels:

| ROI | Interpretation in this exercise |
|---|---|
| Pericalcarine | early visual cortex / V1 proxy |
| Lateral occipital | higher-order visual / OFA-related region |
| Fusiform | ventral visual / FFA-related region |

### In Brainstorm

1. Display one source file on the cortex.
2. Open the **Scout** tab.
3. Select the **Desikan–Killiany** atlas, or the corresponding FreeSurfer atlas available in the protocol.
4. Select the left and right parcels of interest.
5. Display the scout time series.
6. Inspect approximately `0–300 ms`.
7. Compare **Famous**, **Unfamiliar** and **Scrambled**.

Brainstorm scout documentation:

➡️ [Brainstorm Tutorial 23: Scouts](https://neuroimage.usc.edu/brainstorm/Tutorials/Scouts)

### ROI time-series choice

For a polarity-insensitive Brainstorm–MNE comparison, use the same **RMS/power-like summary** in both packages.

If you use signed Mean/PCA time series instead, document the sign-handling convention because cortical orientation can affect the sign.

> **Optional Brainstorm-only demonstration**  
> The original PracticalMEEG tutorial creates small functional scouts around approximately:
>
> - V1: ~85 ms
> - OFA: ~130 ms
> - FFA: ~165 ms
>
> These are useful pedagogically, but atlas-defined ROIs are preferable for the main Brainstorm–MNE comparison because they are not selected from the observed activation.

---

# 12. Record your results

Complete one row for each solution you inspect.

| Method | SNR | Condition | N170 latency | Peak region | Spatial spread | ROI observation |
|---|---:|---|---:|---|---|---|
| MNE | 3 | Famous |  |  |  |  |
| MNE | 3 | Unfamiliar |  |  |  |  |
| MNE | 3 | Scrambled |  |  |  |  |
| dSPM | 3 | Famous |  |  |  |  |
| dSPM | 3 | Unfamiliar |  |  |  |  |
| dSPM | 3 | Scrambled |  |  |  |  |
| sLORETA | 3 | Famous |  |  |  |  |
| sLORETA | 3 | Unfamiliar |  |  |  |  |
| sLORETA | 3 | Scrambled |  |  |  |  |
| dSPM | 1 | Famous |  |  |  |  |
| dSPM | 1 | Unfamiliar |  |  |  |  |
| dSPM | 1 | Scrambled |  |  |  |  |
| dSPM | 5 | Famous |  |  |  |  |
| dSPM | 5 | Unfamiliar |  |  |  |  |
| dSPM | 5 | Scrambled |  |  |  |  |

The aim is **not** to nominate a universally “best” solution.

The aim is to identify:

- what is stable;
- what changes;
- which conclusions depend on methodological choices.

---

# Final Brainstorm × MNE-Python comparison

At the end of the hands-on, the Brainstorm and MNE-Python groups will come back together.

Compare the results in this order.

### 1. Temporal information

- Is the main face-related response found at a similar latency?
- Is the N170 timing robust?

### 2. Spatial information

- Are the strongest cortical regions around 170 ms similar?
- Are differences mainly in localization or in spatial spread?

### 3. ROI time series

- Do the predefined visual ROIs show similar temporal dynamics?
- Are the relative condition effects preserved?

### 4. Experimental effect

Is the pattern across `Famous / Unfamiliar / Scrambled` preserved?

### 5. Inverse-method sensitivity

How much changes when we move between `MNE / dSPM / sLORETA`?

### 6. Regularization sensitivity

How much changes when we move between `SNR = 1 / 3 / 5`?

### 7. Software sensitivity

After matching the main assumptions, how large are the remaining differences between `Brainstorm / MNE-Python` compared with the differences caused by the inverse method or regularization?

---

# Take-home message

> ## How much of a source-reconstruction result belongs to the data, and how much belongs to the choices we make when solving the inverse problem?
>
> **Open Science is not only about sharing data and code.**
>
> It also requires making the methodological assumptions, parameter values and analysis decisions that shape the source estimate:
>
> - explicit,
> - inspectable,
> - reproducible.

---

# References and useful links

- [Brainstorm installation](https://neuroimage.usc.edu/brainstorm/Installation)
- [Brainstorm Tutorial 22: Source estimation](https://neuroimage.usc.edu/brainstorm/Tutorials/SourceEstimation)
- [Brainstorm Tutorial 23: Scouts](https://neuroimage.usc.edu/brainstorm/Tutorials/Scouts)
- [PracticalMEEG 2025 Brainstorm materials](https://zenodo.org/records/17644377)
- [PracticalMEEG 2025 MNE-Python materials](https://zenodo.org/records/18359739)
- [Wakeman & Henson dataset paper](https://www.nature.com/articles/sdata20151)
- [From raw MEG/EEG to publication – Frontiers Research Topic](https://www.frontiersin.org/research-topics/5158/from-raw-megeeg-to-publication-how-to-perform-megeeg-group-analysis-with-free-academic-software/magazine)

---

## Suggested repository structure

```text
brainstorm-source-imaging/
│
├── README.md
├── tutorial/
│   └── brainstorm_source_imaging.md
├── figures/
│   └── ...
├── scripts/
│   └── ...
└── materials/
    └── ...
```

The large PracticalMEEG dataset should remain on **Zenodo** rather than being committed to GitHub.
