package com.tradelab.backend.common;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

	@GetMapping("/api/health")
	HealthResponse health() {
		return new HealthResponse("UP", "TradeLab Backend");
	}

	record HealthResponse(String status, String service) {
	}
}
