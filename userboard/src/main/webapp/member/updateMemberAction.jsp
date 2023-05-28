<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.net.*"%>
<%
	// request 인코딩
	request.setCharacterEncoding("utf-8");

	/* session 유효성 검사
	* session의 값이 null이면 home.jsp 페이지로 리턴
	*/
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}

	// session 값 저장(memberId)
	String memberId = (String)(session.getAttribute("loginMemberId"));
	System.out.println(memberId +"<--updateMemberAction.jsp memberId");
	
	/* 요청값 유효성 검사(changeMemberPw, memberPwCheck)
	* 요청값이 null, ""이 들어왔을 때, changeMemberPw, memberPwCheck의 값이 같지 않을 때 
	* updateMemberForm.jsp에 보여주는 메세지 분기
	* 위에 조건에 해당하면 updateMemberForm.jsp 페이지로 리턴
	*/
	String msg = null;
	if(request.getParameter("changeMemberPw") == null
		|| request.getParameter("changeMemberPw").equals("")){
			msg ="변경할 Password가 입력되지 않았습니다.";
	} else if(request.getParameter("memberPwCheck") == null
		|| request.getParameter("memberPwCheck").equals("")){
			msg ="Password 확인이 입력되지 않았습니다.";
	} else if(!request.getParameter("changeMemberPw").equals(request.getParameter("memberPwCheck"))){
			msg ="Password가 일치하지 않습니다.";
	}
	if(msg != null) {
		String rmsg =  URLEncoder.encode(msg,"utf-8");
		response.sendRedirect(request.getContextPath()+"/member/updateMemberForm.jsp?msg="+rmsg+"&memberId="+memberId);
		return;
	}

	// 값 저장(changeMemberPw)
	String changeMemberPw = request.getParameter("changeMemberPw");
	System.out.println(changeMemberPw + "<-- updateMemberAction.jsp changeMemberPw");
	
	// DB 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	System.out.println("updateMemberAction.jsp db접속 성공");
	
	// updateMember
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "UPDATE member SET member_pw = PASSWORD(?) WHERE member_id = ?";
	stmt = conn.prepareStatement(sql); //(?,1-2)
	stmt.setString(1, changeMemberPw);
	stmt.setString(2, memberId);
	System.out.println(stmt + "<-- updateMemberAction.jsp stmt");
	
	/* redirection 
	* stmt.executeUpdate() 후 변수 row의 값 저장. 값에 따른 페이지 이동
	* row == 0 : updateMemberForm.jsp 페이지 이동. 이동 시 memberId 전달
	* row == 1 : home.jsp 페이지 이동. session.invalidate();
	*/
	int row = stmt.executeUpdate();
	System.out.println(row + "<-- updateMemberAction.jsp row");
	
	if(row == 0){
		response.sendRedirect(request.getContextPath()+"/member/updateMemberForm.jsp?memberId="+memberId);
	}else if(row == 1){
		session.invalidate();
		response.sendRedirect(request.getContextPath()+"/home.jsp");
	}else {
		System.out.println("updateMemberAction.jsp error row값 : "+row);
	}
%>