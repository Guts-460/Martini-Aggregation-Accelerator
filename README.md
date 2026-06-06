# Coarse-Grained Peptide Aggregation Accelerator

This repository provides a Bash scripting pipeline to accelerate the acquisition of molecules aggregates (condensates/droplets) in coarse-grained molecular dynamics simulations using **GROMACS** and the **Martini force field**.

Designed for systems where peptides do not spontaneously aggregate under normal conditions, this pipeline gradually compresses the simulation box, removes water randomly, and re-equilibrates the system to promote controlled aggregation.

---

## 📌 Application Scenarios

| Scenario | Recommended Workflow |
|----------|----------------------|
| Peptides spontaneously assemble or aggregate | Section 2.2 (long unbiased simulation) |
| No spontaneous aggregation, but condensates are needed for downstream studies (e.g., with nucleic acids) | **This pipeline** – stepwise compression + water deletion |

---

## 🧪 Methodology Overview

- **System**: 15 F5A peptides (Martini CG)
- **Simulation length**: 12 × 1 µs steps + final 2 µs equilibration
- **Key operations per step**:
  - Randomly remove ~20% of water molecules
  - Re-equilibrate pressure (box shrinks → concentration increases)
  - Peptides gradually aggregate
- **Energy landscape analysis** possible at each segment (free energy / stability / MD trajectories)

---

## 📁 Directory Structure

```
.
├── common/
│   ├── 1uspre.sh            # Prepare initial 1 µs .tpr file
│   ├── 1us.mdp              # MDP for 1 µs runs
│   ├── 2us.mdp              # MDP for final 2 µs run
│   ├── em.mdp               # Energy minimization
│   └── martini*itp          # Force field files
├── trajs_combine/
│   ├── 01-combin.sh         # Merge trajectory segments
│   ├── 01-getraj.sh         # Process individual trajectory
│   ├── 02-combineq.sh       # Merge with final equilibration
│   └── 02-sepfra.sh         # Extract frames for movies
├── run.sh                    # Master script (12 steps)
├── runequi.sh                # Final 2 µs equilibration
├── runsingle.sh              # Single 1 µs step with water deletion
└── README.md                 # This file
```

---

## ⚙️ Requirements

- GROMACS ≥ 2022.5  
- Python 2.7.18 (for `martinize.py`)  
- Martini force field files  
- Modules environment (adjust `source /opt/modules-...` paths as needed)

> ⚠️ Check and modify paths in:
> - `run.sh`
> - `runequi.sh`
> - `runsingle.sh`
> - `common/1uspre.sh`

---

## 🚀 Execution Instructions

### 1. Prepare initial TPR (first 1 µs)

```bash
cd common
./1uspre.sh
# outputs: 1us.tpr
cd ..
```

### 2. Run the main aggregation pipeline

```bash
nohup ./run.sh > run.log 2>&1 &
```

Monitor progress with `tail -f run.log`.

---

## 🔧 What Each Script Does

| Script | Function |
|--------|----------|
| `1uspre.sh` | Builds initial box (7 nm³), inserts 15 peptides, solvates, adds ions (75 Cl⁻, 100 WF), minimizes, and prepares `1us.tpr` |
| `runsingle.sh` | Performs one 1 µs step: deletes ~20% random water molecules, updates topology, minimizes, runs MD, shrinks box |
| `runequi.sh` | Final 2 µs equilibration after all 12 steps (also deletes water, rebalances) |
| `01-getraj.sh` | PBC correction, cluster/mol wrapping, fit rot+trans, extracts trajectory segments |
| `01-combin.sh` | Concatenates all 1 µs `.xtc` files into a single trajectory |
| `02-combineq.sh` | Merges the 12 µs aggregate trajectory with the final 2 µs equilibration |
| `02-sepfra.sh` | Extracts frames every 10 ns (e.g., for movies) |

---

## 📊 Outputs

- `./1/` to `./12/` – each 1 µs simulation with:
  - `*us.gro`, `*us.xtc`, `*us.tpr`, `em.gro`, `em.top`
- `./equi2us/` – final 2 µs equilibrated aggregate
- `./trajs_combine/f5adrop_all.xtc` – combined trajectory (12 µs + 2 µs)

---

## 🔍 Post‑Processing & Analysis

Use scripts inside `trajs_combine/`:

```bash
cd trajs_combine
./01-combin.sh       # merge all segments
./02-combineq.sh     # add final equilibration
./02-sepfra.sh       # subsample frames (e.g., every 10 ns)
```

Energy landscapes can be computed per segment (e.g., using GROMACS `gmx sham`).

---

## ⚠️ Important Notes

- Random water deletion modifies atom counts – scripts automatically update topologies and `.gro` headers.
- The pipeline assumes:
  - Water residue name = `W`
  - Ion residue name = `CL`
  - Special water-like particles = `WF`
- Adjust `-rdd 2.0` if you encounter domain decomposition errors.

---

## 📝 Customization

Before running, review:

- `run.sh` – number of steps (default 12), initial TPR path  
- `runsingle.sh` – fraction of water retained (currently 80%)  
- `runequi.sh` – final equilibration length (2 µs)  
- `common/1uspre.sh` – box size, number of peptides, ion concentrations  

> For detailed parameter tuning, use an LLM to parse the scripts – they contain system‑specific settings.

---

## 📖 Citation

If you use this pipeline, please cite:

- GROMACS: Abraham et al., *SoftwareX* (2015)  
- Martini force field: de Jong et al., *J. Chem. Theory Comput.* (2013)  

---

## 🤝 Contributing

Issues and pull requests are welcome. Please include your GROMACS version and a brief description of your system.

---

## 📄 License

MIT – use at your own risk. Always validate aggregation behavior with independent simulations.
