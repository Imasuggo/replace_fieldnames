class TestLogic {
	
	/**
	 * @param c
	 */
	void test(int c) {
		
		int a;
		
		int a2;
		
		int b = 1;
		
		TestDto testDto = TestDto
			.builder()
			.a(a)
			.build();
		
		TestDto2 testDto2 = TestDto2
			.builder()
			.a(testDto.getA())
			.build();
	}

}