<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="vo.*"%>
<%
	/* session 유효성 검사
	* session의 값이 null이면 home.jsp 페이지로 이동
	*/
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}
	
	// session 값 저장(memberId)
	String memberId = (String)(session.getAttribute("loginMemberId"));
	System.out.println(memberId +"<-- memberInformation memberId");
	
	// DB 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	System.out.println("memberInformation.jsp db접속 성공");
	
	// select memberInformation 
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "SELECT member_id memberId, member_pw memberPw, createdate, updatedate FROM member where member_id = ?";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, memberId);
	System.out.println(stmt + "<-- memberInformation.jsp stmt");
	rs = stmt.executeQuery();
	
	// vo.Member member(모델데이터)
	Member member = null;
	if(rs.next()){
		member = new Member();
		member.setMemberId(rs.getString("memberId"));
		member.setMemberPw(rs.getString("memberPw"));
		member.setCreatedate(rs.getString("createdate"));
		member.setUpdatedate(rs.getString("updatedate"));
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>memberInformation.jsp</title>
<jsp:include page="/inc/link.jsp"></jsp:include>
</head>
<body>
	<div class="main-container">
		<!-- 메인메뉴(가로) -->		
		<div class="cell-header">
			<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
		</div>
		<div class="cell-content">
			<!-- member 모델 출력-->
			<h4 class="container p-3">회원정보</h4>
			<div class="container p-3">
				<table class="table table-sm">
					<tr>
						<td>아이디</td>
						<td>
							<%=member.getMemberId()%>
						</td>
					</tr>
					<tr>
						<td>가입일</td>
						<td>
							<%=member.getCreatedate().substring(0,10)%>
						</td>
					</tr>
					<tr>
						<td>정보 수정일</td>
						<td>
							<%=member.getUpdatedate().substring(0,10)%>
						</td>
					</tr>
				</table>
			</div>
			<div class="container p-3 text-right">
				<a href = "<%=request.getContextPath()%>/member/updateMemberForm.jsp" class="btn">비밀번호변경</a>
				<a href = "<%=request.getContextPath()%>/member/deleteMemberForm.jsp" class="btn">회원탈퇴</a>
			</div>
		</div>
		<div class="cell-footer">
			<jsp:include page="/inc/copyright.jsp"></jsp:include>
		</div>
	</div>
</body>
</html>