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
	System.out.println(memberId +"<-- deleteMemberForm.jsp memberId");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>deleteMemberForm.jsp</title>
<jsp:include page="/inc/link.jsp"></jsp:include>
</head>
<body>
	<!-- 메인메뉴(가로) -->	
	<div class="main-container">
		<div class="cell-header">
			<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
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
			<!-- 삭제 폼 -->
			<h4>회원 탈퇴</h4>
			<div class="delete_form">	
				<form action="<%=request.getContextPath()%>/member/deleteMemberActtion.jsp" method="post">
					<div class="delete_member_div">
					<strong>회원탈퇴를 위해 비밀번호를 입력해주세요</strong>
						<div class="delete_pw">
							<div>
								<input type="password" name="memberPw" id="memberPw" class="memberPw" placeholder="비밀번호">
							</div>
						</div>
						<div class="delete_btn">	
							<button type="submit" class="sign_in_btn">회원탈퇴</button>
						</div>
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