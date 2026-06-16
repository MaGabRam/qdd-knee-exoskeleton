# Low-Cost QDD Knee Exoskeleton

Preliminary design of a low-cost quasi-direct drive knee actuator for pediatric orthosis/exoskeleton applications.

## Overview

This repository contains the preliminary development of a low-cost quasi-direct drive (QDD) actuator intended for knee assistance in a pediatric orthosis or exoskeleton system. The project integrates CAD modeling, basic motion simulation, finite element analysis, thermal evaluation and MATLAB/Simulink-based dynamic analysis.

The current work corresponds to an academic design stage focused on evaluating the feasibility of the mechanical concept, actuator integration and basic knee flexion-extension motion.

## CAD Assembly Preview

The following image shows the preliminary SolidWorks assembly of the knee actuator and its integration concept with the orthosis structure.

![CAD Assembly](media/cad_assembly.png)

## Motion Study

A preliminary motion study was developed in SolidWorks to visualize the flexion-extension movement of the knee actuator before physical prototyping.

[Watch motion preview](media/motion_preview.mp4)

## Finite Element Analysis Preview

A preliminary finite element analysis was performed to evaluate the mechanical behavior of selected components under design loads.

![FEA Study](media/fea_study.png)

## Repository Structure

```text
low-cost-qdd-knee-exoskeleton/
│
├── media/
│   ├── cad_assembly.png
│   ├── fea_study.png
│   └── motion_preview.mp4
│
├── matlab/
│   ├── evaluacion_termica_actuador/
│   └── investigacion_dinamico/
│
│
└── documentation/
```

## MATLAB and Simulink Files

The `matlab/` folder contains the scripts and simulation files used for the preliminary analytical evaluation of the actuator.

### Thermal Evaluation

```text
matlab/evaluacion_termica_actuador/
```

This folder includes the MATLAB script and spreadsheet used for the preliminary thermal evaluation of the QDD actuator.

Main files:

* `evaluacion_termica_qdd.m`
* `resultados_termicos_qdd.xlsx`

### Dynamic and Control Analysis

```text
matlab/investigacion_dinamico/
```

This folder includes MATLAB and Simulink files related to the dynamic/control analysis of the knee actuator.

Main files:

* `control_rodilla_mvp.m`
* `parametros_control_rodilla.m`
* `control_rodilla_simulink.slx`
* `resultados_control_dinamico_rodilla.xlsx`



## Current Project Status

The project is currently in the preliminary design and simulation stage. The main completed tasks include:

* Initial CAD modeling of the actuator and orthosis integration concept.
* Basic flexion-extension motion study in SolidWorks.
* Preliminary finite element analysis of selected components.
* MATLAB-based thermal evaluation.
* MATLAB/Simulink-based dynamic and control analysis.
* Organization of technical files for academic documentation.

## Tools Used

* MATLAB
* Simulink
* SolidWorks
* SolidWorks Motion Study
* SolidWorks Simulation
* GitHub

## Notes

This repository is intended for academic documentation and preliminary design validation. The CAD models, simulation files and analytical scripts may change as the design evolves.

Generated MATLAB/Simulink cache files are not required to understand or reproduce the main project logic and may be excluded from future commits.

## Author

Mariel Gabriela Valeriano Ramos
Mechatronics Engineering
Universidad Católica Boliviana “San Pablo”
Taller de Grado I – 2026
