@testable import DockerSwift

extension VersionEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.base64EncodedString("eyJQbGF0Zm9ybSI6eyJOYW1lIjoibGludXgvYXJtNjQvZmVkb3JhLTQwIn0sIkNvbXBvbmVudHMiOlt7Ik5hbWUiOiJQb2RtYW4gRW5naW5lIiwiVmVyc2lvbiI6IjUuMi4zIiwiRGV0YWlscyI6eyJBUElWZXJzaW9uIjoiNS4yLjMiLCJBcmNoIjoiYXJtNjQiLCJCdWlsZFRpbWUiOiIyMDI0LTA5LTIzVDE5OjAwOjAwLTA1OjAwIiwiRXhwZXJpbWVudGFsIjoiZmFsc2UiLCJHaXRDb21taXQiOiIiLCJHb1ZlcnNpb24iOiJnbzEuMjIuNyIsIktlcm5lbFZlcnNpb24iOiI2LjEwLjEwLTIwMC5mYzQwLmFhcmNoNjQiLCJNaW5BUElWZXJzaW9uIjoiNC4wLjAiLCJPcyI6ImxpbnV4In19LHsiTmFtZSI6IkNvbm1vbiIsIlZlcnNpb24iOiJjb25tb24gdmVyc2lvbiAyLjEuMTIsIGNvbW1pdDogIiwiRGV0YWlscyI6eyJQYWNrYWdlIjoiY29ubW9uLTIuMS4xMi0yLmZjNDAuYWFyY2g2NCJ9fSx7Ik5hbWUiOiJPQ0kgUnVudGltZSAoY3J1bikiLCJWZXJzaW9uIjoiY3J1biB2ZXJzaW9uIFVOS05PV05cbmNvbW1pdDogZmE2MWQ2MTMzNDUyMWJiMjA1NDMwZTkyOGRmOTlmOTQ3NzE2Zjg4Y1xucnVuZGlyOiAvcnVuL3VzZXIvNTAxL2NydW5cbnNwZWM6IDEuMC4wXG4rU1lTVEVNRCArU0VMSU5VWCArQVBQQVJNT1IgK0NBUCArU0VDQ09NUCArRUJQRiArQ1JJVSArTElCS1JVTiArV0FTTTp3YXNtZWRnZSArWUFKTCIsIkRldGFpbHMiOnsiUGFja2FnZSI6ImNydW4tMS4xNy0xLjIwMjQwOTEwMTIxMTQ0NTAyOTM3Lm1haW4uMy5nNGFiNGFjMC5mYzQwLmFhcmNoNjQifX1dLCJWZXJzaW9uIjoiNS4yLjMiLCJBcGlWZXJzaW9uIjoiMS40MSIsIk1pbkFQSVZlcnNpb24iOiIxLjI0IiwiR2l0Q29tbWl0IjoiIiwiR29WZXJzaW9uIjoiZ28xLjIyLjciLCJPcyI6ImxpbnV4IiwiQXJjaCI6ImFybTY0IiwiS2VybmVsVmVyc2lvbiI6IjYuMTAuMTAtMjAwLmZjNDAuYWFyY2g2NCIsIkJ1aWxkVGltZSI6IjIwMjQtMDktMjNUMTk6MDA6MDAtMDU6MDAifQ==")
		]
	}
}
