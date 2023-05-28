<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	/* session 유효성 검사
	* session의 값이 null이면 home.jsp 페이지로 리턴
	*/
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}
	
	// session 값 저장(memberId)
	String memberId = (String)(session.getAttribute("loginMemberId"));
	System.out.println(memberId +"<--memberInformation memberId");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>updateMemberForm.jsp</title>
</head>
<body>
	<!-- 메인메뉴(가로) -->	
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<!-- 메세지 확인 -->
	<div>
		<%
			String msg = request.getParameter("msg");
			if(msg != null){
		%>
			<%=msg%>
		<%		
			}
		%>
	</div>
	
	<!-- 정보 수정 폼 -->
	<form action="<%=request.getContextPath()%>/member/updateMemberAction.jsp" method="post">
		<div>
			<table>
				<tr>
					<td>ID</td>
					<td>
						<input type="text" name="memberId" value="<%=memberId%>" readonly="readonly">
					</td>
				</tr>
				<tr>
					<td>NewPassword</td>
					<td>
						<input type="password" name="changeMemberPw">
					</td>
				</tr>
				<tr>
					<td>Password Check</td>
					<td>
						<input type="password" name="memberPwCheck">
					</td>
				</tr>
			</table>
			
			<div>
				<button type="submit">비밀번호변경</button>
			</div>
		</div>
	</form>
	
	<div>
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</body>
</html>