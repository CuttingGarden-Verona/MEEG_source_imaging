# Brainstorm — EEG Source Imaging Hands-on

This folder contains the material for the **Brainstorm group** of the Source Imaging hands-on at **CuttingGardens 2026 – Verona Garden**.

We will analyze EEG data from the **Wakeman & Henson face-processing dataset** using subject **sub-01, Run 01** and the conditions:

**Famous · Unfamiliar · Scrambled**

The goal is to explore how source estimates change when we vary the **inverse method** and **regularization**, while keeping the data and forward model fixed.

## Before the hands-on

Install Brainstorm:

- [Brainstorm installation](https://neuroimage.usc.edu/brainstorm/Installation)

Download the prepared protocol:

- [PracticalMEEG_Single_Precomputed.zip](https://zenodo.org/records/17644377/files/PracticalMEEG_Single_Precomputed.zip?download=1)

Original PracticalMEEG training material:

- [PracticalMEEG 2025 Brainstorm materials](https://zenodo.org/records/17644377)

## Tutorial

➡️ [EEG Source Imaging with Brainstorm](tutorial.md)

During the hands-on we will compare:

- **MNE, dSPM and sLORETA**
- different regularization levels (`SNR = 1, 3, 5`)
- source maps around the **N170 (~170 ms)**
- time series from predefined visual ROIs

At the end, the Brainstorm group will compare its results with the **MNE-Python group**.

## Useful links

- [Brainstorm Source Estimation tutorial](https://neuroimage.usc.edu/brainstorm/Tutorials/SourceEstimation)
- [Brainstorm Scouts tutorial](https://neuroimage.usc.edu/brainstorm/Tutorials/Scouts)
- [Wakeman & Henson dataset](https://www.nature.com/articles/sdata20151)

> **Take-home message:** Source reconstruction depends not only on the data, but also on the methodological choices used to solve the inverse problem.

## Credits

This hands-on is adapted from the Brainstorm training materials developed for
[PracticalMEEG 2025](https://cuttingeeg.org/practicalmeeg2025/) by
Takfarinas Medani, Guiomar Niso, Raymundo Cassani, Anne-Sophie Dubarry,
John Mosher, Sylvain Baillet, and Richard Leahy.

Original materials:
[Medani et al., *PracticalMEEG2025: Brainstorm hands-on tutorial*](https://doi.org/10.5281/zenodo.17644377).
