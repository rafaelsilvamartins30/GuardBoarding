package com.example.architecture;

import static com.tngtech.archunit.library.Architectures.layeredArchitecture;

import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

@AnalyzeClasses(packages = "com.example")
class ArchitectureTest {

  // Example: replace packages and dependencies according to the chosen architecture.
  @ArchTest
  static final ArchRule layersMustRespectTheDefinedFlow =
      layeredArchitecture()
          .consideringAllDependencies()
          .layer("Controller").definedBy("..controller..")
          .layer("Service").definedBy("..service..")
          .layer("Repository").definedBy("..repository..")
          .whereLayer("Repository").mayOnlyBeAccessedByLayers("Service");
}
