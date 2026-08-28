package com.example.architecture;

import static com.tngtech.archunit.library.Architectures.layeredArchitecture;

import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

@AnalyzeClasses(packages = "com.example")
class ArchitectureTest {

  // Exemplo: troque pacotes e dependências conforme a arquitetura decidida.
  @ArchTest
  static final ArchRule layersMustRespectTheDefinedFlow =
      layeredArchitecture()
          .consideringAllDependencies()
          .layer("Controller").definedBy("..controller..")
          .layer("Service").definedBy("..service..")
          .layer("Repository").definedBy("..repository..")
          .whereLayer("Controller").mayNotAccessLayers("Repository");
}
