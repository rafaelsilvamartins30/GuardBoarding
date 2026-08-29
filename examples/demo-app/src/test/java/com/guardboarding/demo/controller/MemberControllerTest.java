package com.guardboarding.demo.controller;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.guardboarding.demo.dto.CreateMemberRequest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class MemberControllerTest {

  @Autowired private MockMvc mockMvc;

  @Autowired private ObjectMapper objectMapper;

  @Test
  void shouldCreateAndRetrieveMember() throws Exception {
    CreateMemberRequest request =
        new CreateMemberRequest("Lucas Tech", "lucas@example.com", "Tech Lead");

    String responseBody =
        mockMvc
            .perform(
                post("/api/members")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id").exists())
            .andExpect(jsonPath("$.name").value("Lucas Tech"))
            .andReturn()
            .getResponse()
            .getContentAsString();

    String id = objectMapper.readTree(responseBody).get("id").asText();

    mockMvc
        .perform(get("/api/members/" + id))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.email").value("lucas@example.com"));
  }

  @Test
  void shouldReturn404ForUnknownMember() throws Exception {
    mockMvc.perform(get("/api/members/non-existent-id")).andExpect(status().isNotFound());
  }
}
