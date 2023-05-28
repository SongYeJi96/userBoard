<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	/* session 유효성 검사
	* session의 값이 null이 아니면 home.jsp 페이지로 리턴
	*/
	if(session.getAttribute("loginMemberId") != null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>insertMemberForm.jsp</title>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://kit.fontawesome.com/ba8d291cc0.js" crossorigin="anonymous"></script>
</head>
<body>
	<!-- 메인메뉴(가로) -->
	<div>
		<i class='fas fa-home iheader homeI' onclick="location.href='<%=request.getContextPath()%>/home.jsp'"></i>
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
	
	<!-- 회원가입 폼 -->
	<h4>회원가입</h4>
	<form action="<%=request.getContextPath()%>/member/insertMemberAction.jsp" method="post">
		<table>
			<tr>
				<td>
					<label for="memberId">ID</label>
				</td>
				<td>
					<input type="text" name="memberId" id="memberId">
				</td>
			</tr>
			<tr>
				<td>
					<label for="memberPw">Password</label>
				</td>
				<td>
					<input type="password" name="memberPw" id="memberPw">
				</td>
			</tr>
		</table>
		<button type="submit">회원가입</button>
	</form>
	<div>
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</body>
</html>