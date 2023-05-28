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
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://kit.fontawesome.com/ba8d291cc0.js" crossorigin="anonymous"></script>
<style>
	*{
		margin :0;
		padding :0;
	}
	.container{
		height: 100%;
		margin: 0;
		padding: 0;
		display: grid;
		grid-template : 70px 1fr 100px / 0px 1fr;
		grid-gap: 0px;
		min-height: 100vh;
		min-width: 100%;
	}
	.cell-header{
		display: flex;
		padding: 30px;
		grid-column: 1 / 3;
		justify-content: center; 
		align-items: center; 	
	}
	.cell-content{
		display: inline;
		padding: 30px;
		grid-column: 1 / 3;
		text-align: center;
	}
	.cell-footer{
		display: flex;
		grid-column: 1 / 3;
		background-color: #191919;
		color: #FFFFFF;
		justify-content: center;
		align-items: center; 	
	}
	.homeI{
		font-size: 30px;
	}
	.homeI:hover{
		cursor: pointer;
	}
	.sign_in_form{
		display:flex;
		padding: 20px;
		justify-content: center;
	}
	.sign_in{
		padding: 20px;
		border: solid 2px #191919;
		border-radius: 10px;
		padding-top: 30px;
		padding-bottom: 30px;
		width: 400px;	
	}
	.sign_in_id{
		padding-top: 10px;
	}
	.sign_in_pw{
		padding-top: 30px;
	}
	.sign_in_id_label{
		text-align: left;
	}
	.sign_in_pw_label{
		text-align: left;
	}
	.sign_in_btn_div{
		display: flex;
		justify-content: center;
		padding-top: 30px;
	}
	.memberId, .memberPw{
		width: 100%;
		height: 40px;
		border-radius: 5px;
	}
	.sign_in_btn{
		border-radius: 5px;
		background-color: #000042;
		color:#FFFFFF;
		width: 100%;
		height: 40px;
	}
	.sign_in_btn:hover{
		background-color: #000030;
	}
	.sign_up{
		padding: 20px;
		margin-top: 20px;
		border: solid 2px #191919;
		border-radius: 10px;
	}
	.sign_up_a{
		text-decoration: none;
		color: #0100FF;
	}
</style>
</head>
<body>
	<div class="container">
		<!-- 로그인폼 메인메뉴 -->
		<div class="cell-header">
			<i class='fas fa-home iheader homeI' onclick="location.href='<%=request.getContextPath()%>/home.jsp'"></i>
		</div>
		<div  class="cell-content">
			<!-- 메세지 확인 -->
			<div class="msg">
				<%
					String msg = request.getParameter("msg");
					if(msg != null){
				%>
					<%=msg%>
				<%		
					}
				%>
			</div>
			<div>
				<h4>Blog 로그인</h4>
			</div>
		
			<!-- 로그인폼 -->
			<div class="sign_in_form">	
				<form action="<%=request.getContextPath()%>/member/loginAction.jsp" method="post">
					<div class="sign_in">
						<div class=sign_in_id>
							<div class="sign_in_id_label">
								<label for="memberId">Id</label>
							</div>
							<div>
								<input type="text" name="memberId" id="memberId" class="memberId">
							</div>
						</div>
						<div class="sign_in_pw">
							<div class="sign_in_id_label">
								<label for="memberPw">Password</label>
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