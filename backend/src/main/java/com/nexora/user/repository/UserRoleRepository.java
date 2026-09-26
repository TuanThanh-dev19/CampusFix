package com.nexora.user.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.nexora.user.entity.UserRole;
import com.nexora.user.entity.UserRoleId;

public interface UserRoleRepository extends JpaRepository<UserRole, UserRoleId> {
}
