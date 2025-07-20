// Enhanced ProjectProgress enum with better organization
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kawa_web/core/creatingProjectListener/creatingProjectListener.dart';
import 'package:kawa_web/pages/home/homePage.dart';
import 'package:kawa_web/widgets/custom/custom.dart';

enum ProjectProgress {
  // Initial state
  notStarted('Not_Started'),

  // Project Plan phase
  creatingProjectPlan('Creating_Project_Plan'),
  createdProjectPlan('Created_Project_Plan'),
  failedToCreateProjectPlan('Failed_To_Create_Project_Plan'),

  // Project Creation phase
  creatingProject('Creating_Project'),
  createdProject('Created_Project'),
  failedToCreateProject('Failed_To_Create_Project'),

  // Navigation Structure phase
  creatingProjectNavigationStructure('Creating_Project_Navigation_Structure'),
  createdProjectNavigationStructure('Created_Project_Navigation_Structure'),
  failedToCreateProjectNavigationStructure(
      'Failed_To_Create_Project_Navigation_Structure'),

  // Navigation Flow phase
  creatingProjectNavigationFlow('Creating_Project_Navigation_Flow'),
  createdProjectNavigationFlow('Created_Project_Navigation_Flow'),
  failedToCreateProjectNavigationFlow(
      'Failed_To_Create_Project_Navigation_Flow'),

  // Project Screens phase
  creatingProjectScreens('Creating_Project_Screens'),
  createdProjectScreens('Created_Project_Screens'),
  failedToCreateProjectScreens('Failed_To_Create_Project_Screens'),

  // Flutter Project phase
  creatingFlutterProject('Creating_Flutter_Project'),
  createdFlutterProject('Created_Flutter_Project'),
  failedToCreateFlutterProject('Failed_To_Create_Flutter_Project'),

  // Launch phase
  launchingProject('Launching_Project'),
  projectLaunched('Project_Launched'),
  failedToLaunchProject('Failed_To_Launch_Project');

  const ProjectProgress(this.value);
  final String value;

  // Helper method to get enum from string value
  static ProjectProgress? fromString(String value) {
    for (ProjectProgress progress in ProjectProgress.values) {
      if (progress.value == value) return progress;
    }
    return null;
  }

  // Helper methods for status checking
  bool get isCreating => value.startsWith('Creating_');
  bool get isCreated => value.startsWith('Created_');
  bool get isFailed => value.startsWith('Failed_');
  bool get isLaunching => this == ProjectProgress.launchingProject;
  bool get isLaunched => this == ProjectProgress.projectLaunched;
}

// Progress phase grouping for better organization
enum ProgressPhase {
  projectPlan('Creating_Project_Plan'),
  project('Creating_Project'),
  navigationStructure('Creating_Project_Navigation_Structure'),
  navigationFlow('Created_Project_Navigation_Flow'),
  projectScreens('Creating_Project_Screens'),
  flutterProject('Creating_Flutter_Project'),
  launching('Launching_Project'),
  launched('Project_Launched');

  const ProgressPhase(this.sectionId);
  final String sectionId;
}

// Optimized progress handler class
class ProjectProgressHandler {
  final List<FeatureSectionModel> _listProgress;
  late StreamSubscription _subscription;

  ProjectProgressHandler(this._listProgress);

  // Optimized progress mapping
  static final Map<ProjectProgress, ProgressPhase> _progressPhaseMap = {
    // Project Plan phase
    ProjectProgress.creatingProjectPlan: ProgressPhase.projectPlan,
    ProjectProgress.createdProjectPlan: ProgressPhase.projectPlan,
    ProjectProgress.failedToCreateProjectPlan: ProgressPhase.projectPlan,

    // Project phase
    ProjectProgress.creatingProject: ProgressPhase.project,
    ProjectProgress.createdProject: ProgressPhase.project,
    ProjectProgress.failedToCreateProject: ProgressPhase.project,

    // Navigation Structure phase
    ProjectProgress.creatingProjectNavigationStructure:
        ProgressPhase.navigationStructure,
    ProjectProgress.createdProjectNavigationStructure:
        ProgressPhase.navigationStructure,
    ProjectProgress.failedToCreateProjectNavigationStructure:
        ProgressPhase.navigationStructure,

    // Navigation Flow phase
    ProjectProgress.creatingProjectNavigationFlow: ProgressPhase.navigationFlow,
    ProjectProgress.createdProjectNavigationFlow: ProgressPhase.navigationFlow,
    ProjectProgress.failedToCreateProjectNavigationFlow:
        ProgressPhase.navigationFlow,

    // Project Screens phase
    ProjectProgress.creatingProjectScreens: ProgressPhase.projectScreens,
    ProjectProgress.createdProjectScreens: ProgressPhase.projectScreens,
    ProjectProgress.failedToCreateProjectScreens: ProgressPhase.projectScreens,

    // Flutter Project phase
    ProjectProgress.creatingFlutterProject: ProgressPhase.flutterProject,
    ProjectProgress.createdFlutterProject: ProgressPhase.flutterProject,
    ProjectProgress.failedToCreateFlutterProject: ProgressPhase.flutterProject,

    // Launch phase
    ProjectProgress.launchingProject: ProgressPhase.launching,
    ProjectProgress.projectLaunched: ProgressPhase.launched,
    ProjectProgress.failedToLaunchProject: ProgressPhase.launching,
  };

  void startListening(VoidCallback onUpdate) {
    resetProgress();
    _subscription = CreatingProjectListener.streamController.stream
        .listen((progressString) {
      final progress = ProjectProgress.fromString(progressString);
      if (progress != null) {
        _updateProgress(progress);
        onUpdate();
      }
    });
  }

  void resetProgress() {
    for (var section in _listProgress) {
      section.status = FeatureSectionStatus.none;
      for (var card in section.cards) {
        card.status = FeatureSectionStatus.none;
      }
    }
  }

  void _updateProgress(ProjectProgress progress) {
    final phase = _progressPhaseMap[progress];
    if (phase == null) return;

    final section = _findSection(phase.sectionId);
    final card = _findCard(phase.sectionId);
    final status = _getStatusFromProgress(progress);
    if (section != null) {
      section.status = status;
    }
    if (card != null) {
      card.status = status;
    }
  }

  FeatureSectionStatus _getStatusFromProgress(ProjectProgress progress) {
    if (progress.isCreating || progress.isLaunching) {
      return FeatureSectionStatus.loading;
    } else if (progress.isCreated || progress.isLaunched) {
      return FeatureSectionStatus.done;
    } else if (progress.isFailed) {
      return FeatureSectionStatus.fail;
    }
    return FeatureSectionStatus.loading; // default
  }

  FeatureSectionModel? _findSection(String sectionId) {
    try {
      return _listProgress.firstWhere((section) => section.id == sectionId);
    } catch (e) {
      return null;
    }
  }

  FeatureCardModel? _findCard(String cardId) {
    try {
      return _listProgress
          .expand((section) => section.cards)
          .firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
