<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@page import="java.net.*"%>
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
	System.out.println(memberId +"<-- deleteMemberAction.jsp memberId");
	
	/* 요청값 유효성 검사(memberPw)
	* memberPw의 null, ""값이 들어오면 deleteMemberForm.jsp 페이지로 리턴
	* 페이지 이동시 memberId, msg 전달
	*/
	if(request.getParameter("memberPw") == null
		|| request.getParameter("memberPw").equals("")){
		String msg = URLEncoder.encode("비밀번호 값이 입력되지 않았습니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/member/deleteMemberForm.jsp?memberId="+memberId+"&msg="+msg);
		return;
	}
	// 값 저장(memberPw)
	String memberPw = request.getParameter("memberPw");
	System.out.println(memberPw + "<-- deleteMemberActoin.jsp memberPw");
	
	// DB 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	System.out.println("deleteMemberrAction.jsp db접속 성공");
	
	// deleteMemberAction
	String sql = "DELETE FROM member where member_id = ? and member_pw = PASSWORD(?)";
	PreparedStatement stmt = conn.prepareStatement(sql); //(?,1-2)
	stmt.setString(1, memberId);
	stmt.setString(2, memberPw);
	System.out.println(stmt + "<-- deleteMemberAction.jsp stmt");
	
	/* redirection
	* stmt.executeUpdate() 후 변수 row의 값 저장. 값에 따른 페이지 이동
	* row == 0 : deleteMemberForm.jsp. 이동시 memberId, 메세지 전달
	* row == 1 : home.jsp. session.invalidate()
	*/
	int row = stmt.executeUpdate();
	System.out.println(row + "<-- deleteMemberAction.jsp");
	if(row == 0){
		String incorrectPw = URLEncoder.encode("비밀번호가 맞지않습니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/member/deleteMemberForm.jsp?memberId="+memberId+"&msg="+incorrectPw);
	}else if(row == 1){
		session.invalidate();
		response.sendRedirect(request.getContextPath()+"/home.jsp");
	}else {
		System.out.println("error row값 : "+row);
	}
%>