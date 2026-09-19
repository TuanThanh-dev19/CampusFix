package com.campusfix;

import org.springframework.boot.SpringApplication;

public class TestCampusFixBackendApplication {

	public static void main(String[] args) {
		SpringApplication.from(CampusFixBackendApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
