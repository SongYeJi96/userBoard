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
<jsp:include page="/inc/link.jsp"></jsp:include>
</head>
<body>
	<div class="main-container">
		<!-- 메인메뉴(가로) -->		
		<div class="cell-header">
			<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
		</div>
		<div class="cell-content">
			<!-- 메세지 확인 -->
			<div class="container p-3">
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
			<h4 class="container p-3">비밀번호 변경</h4>
			<form action="<%=request.getContextPath()%>/member/updateMemberAction.jsp" method="post">
				<div class="container p-3">
					<table class="table table-sm">
						<tr>
							<td>아이디</td>
							<td>
								<%=memberId%>
							</td>
						</tr>
						<tr>
							<td>새로운 비밀번호</td>
							<td>
								<input type="password" name="changeMemberPw" class="form-control w-25">
							</td>
						</tr>
						<tr>
							<td>비밀번호 확인</td>
							<td>
								<input type="password" name="memberPwCheck" class="form-control w-25">
							</td>
						</tr>
					</table>
					
					<div class="container p-3 text-right">
						<button type="submit" class="btn">확인</button>
					</div>
				</div>
			</form>
		</div>
		<div class="cell-footer">
			<jsp:include page="/inc/copyright.jsp"></jsp:include>
		</div>
	</div>
</body>
</html>