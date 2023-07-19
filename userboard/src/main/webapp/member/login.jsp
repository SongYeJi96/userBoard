<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	/* session 유효성 검사
	* session의 값이 null이 아니면 home.jsp 페이지로 리턴
	*/
	if(session.getAttribute("loginMemberId") != null){
		response.sendRedirect(request.getContextPath()+"home.jsp");
		return;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>loginForm.jsp</title>
<jsp:include page="/inc/link.jsp"></jsp:include>
</head>
<body>
	<div class="main-container">
		<!-- 메인메뉴 -->
		<div class="signIn-cell-header">
			<i class='fas fa-home iheader homeI' onclick="location.href='<%=request.getContextPath()%>/home.jsp'"></i>
		</div>
		<div class="signIn-cell-content">
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
			
			<!-- 로그인폼 -->
			<h4>Blog 로그인</h4>
			<div class="sign_in_form">	
				<form action="<%=request.getContextPath()%>/member/loginAction.jsp" method="post">
					<div class="sign_in">
						<div class=sign_in_id>
							<div class="text-left">
								<label for="memberId">아이디</label>
							</div>
							<div>
								<input type="text" name="memberId" id="memberId" class="memberId">
							</div>
						</div>
						<div class="sign_in_pw">
							<div class="text-left">
								<label for="memberPw">비밀번호</label>
							</div>
							<div>
								<input type="password" name="memberPw" id="memberPw" class="memberPw">
							</div>
						</div>
						<div class="sign_in_btn_div">	
							<button type="submit" class="sign_in_btn">로그인</button>
						</div>
					</div>
					<div class="sign_up">
						<a>회원이 아니신가요?</a>
						<a href="<%=request.getContextPath()%>/member/insertMemberForm.jsp" class="sign_up_a">회원가입</a>
					</div>
				</form>
			</div>
		</div>
		<div class="cell-footer">
			<jsp:include page="/inc/copyright.jsp"></jsp:include>
		</div>
	</div>
</body>
</html>