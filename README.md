# Pan3D + VTK (ANARI) Setup Guide

This README provides step-by-step instructions for setting up a Python environment for **Pan3D** with a custom-built **VTK** that has the **ANARI** rendering module enabled.

---

## 📦 Prerequisites

- **Anaconda** (or Python 3.9+ with `venv`)
- **Build tools:** `git`, `cmake` (≥ 3.24), a modern C/C++ compiler
- **ANARI SDK and back-end** (e.g. **helide**, **VisRTX**)

---

## 🐍 1. Create a Python Virtual Environment

**Using Conda (recommended):**
```bash
conda create --name pan3d python=3
conda activate pan3d
```

**Using venv (if Conda not installed):**
```bash
python3 -m venv ~/.venvs/pan3d
source ~/.venvs/pan3d/bin/activate
python -m pip install --upgrade pip
```

## 📥 2. Install Pan3D
```bash
pip uninstall -y vtk
```

## 🗑️ 3. Remove Any Prebuilt VTK
Pan3D requires VTK built with ANARI support:
```bash
pip uninstall -y vtk
```

## 🏗️ 4) Build VTK with ANARI Enabled
```bash
git clone --recursive git@gitlab.kitware.com:vtk/vtk.git VTK
cd VTK
git checkout tags/v9.5.2
cd ..
mkdir vtk_build
cd vtk_build
./vtkbuild_python.sh
```
> [!NOTE]
> Make sure you update `vtkbuild_python.sh` to reflect your system setup.
> (e.g. `vtk_inst_path` and `-Danar_DIR`)

## 📦 5. Build & Install the VTK Python Wheel
```bash
python setup.py bdist_wheel
pip install dist/vtk-*.whl
```

## 🌍 6. Run Pan3D Explorers from the Fork
```bash
git clone git@github.com:griffin28/pan3d.git pan3d_fork
cd pan3d_fork/src/pan3d/explorers

export ANARI_LIBRARY=helide

python globe.py
```





