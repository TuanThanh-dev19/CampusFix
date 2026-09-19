package com.campusfix;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootTest
@Import(TestcontainersConfiguration.class)
@EnabledIfEnvironmentVariable(named = "RUN_SQLSERVER_IT", matches = "(?i)true")
class SqlServerMigrationIntegrationTest {

	@Autowired
	private JdbcTemplate jdbcTemplate;

	@Test
	void flywayCreatesTheSqlServerSchemaAndSeedData() {
		Integer tableCount = jdbcTemplate.queryForObject("""
				SELECT COUNT(*)
				FROM sys.tables
				WHERE name IN ('app_users', 'assets', 'incident_categories', 'tickets')
				""", Integer.class);
		Integer categoryCount = jdbcTemplate.queryForObject(
				"SELECT COUNT(*) FROM dbo.incident_categories", Integer.class);

		assertThat(tableCount).isEqualTo(4);
		assertThat(categoryCount).isGreaterThanOrEqualTo(4);
	}
}
