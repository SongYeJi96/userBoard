<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.net.*"%>
<%@ page import="vo.*"%>
<%
	// request 인코딩
	request.setCharacterEncoding("utf-8");
	
	/* session 유효성 검사
	* session의 값이 null이 아니면 home.jsp 페이지로 리턴
	*/
	if(session.getAttribute("loginMemberId") != null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}
	
	/* 요청값 유효성 검사(memberId, memberPw)
	* 요청값이 null, ""이 들어왔을 때 inserMemberForm.jsp에 보여주는 메세지 분기
	* 위에 조건에 해당하면 insertMemberForm.jsp 페이지로 리턴. 메세지 전달
	*/
	String msg = null;
	if(request.getParameter("memberId") == null
		|| request.getParameter("memberId").equals("")){
	msg = "Id가 입력되지 않았습니다.";
	} else if(request.getParameter("memberPw") == null
		|| request.getParameter("memberPw").equals("")){
	msg = "Password가 입력되지 않았습니다.";
	}
	if(msg != null) {
    	String rmsg =  URLEncoder.encode(msg,"utf-8");
    	response.sendRedirect(request.getContextPath()+"/member/insertMemberForm.jsp?msg="+rmsg);
		return;
	}
	
	// 값 저장
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	// 디버깅 코드
	System.out.println(memberId + "<-- insertMemberAction.jsp memberId");
	System.out.println(memberPw + "<-- insertMemberAction.jsp memberPw");
	
	// vo.Member 객체 만들어 저장 
	Member paramMember = new Member();
	paramMember.setMemberId(memberId);
	paramMember.setMemberPw(memberPw);
	
	// DB 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	
	// 중복되는 id가 있는지 조회
	PreparedStatement duplicateStmt = null;
	ResultSet duplicateRs = null;
	
	String duplicateSql = "SELECT member_id memberId FROM member where member_id = ?";
	duplicateStmt = conn.prepareStatement(duplicateSql);
	duplicateStmt.setString(1, memberId);
	
	System.out.println(duplicateStmt + "<-- insertMemberAction duplicateStmt");
	duplicateRs = duplicateStmt.executeQuery();
	
	if(duplicateRs.next()){
		msg = URLEncoder.encode("중복된 ID입니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/insertMemberForm.jsp?msg=" + msg);
		return;
	}
	
	// insertMember
	PreparedStatement addMemberStmt = null;
	String addMemberSql = "INSERT INTO member(member_id, member_pw, createdate, updatedate) VALUES(?, PASSWORD(?), NOW(), NOW())";
	
	addMemberStmt = conn.prepareStatement(addMemberSql);
	addMemberStmt.setString(1, memberId);
	addMemberStmt.setString(2, memberPw);
	
	System.out.println(addMemberStmt + "<-- insertMemberAction addMemberStmt");
	
	/* redirection 
	* addMemberStmt.executeUpdate() 후 변수 row의 값 저장. 값에 따른 페이지 이동
	* row == 0 : insertMemberForm.jsp
	* row == 1 : home.jsp
	*/
	int row = addMemberStmt.executeUpdate();
	System.out.println(row+"<-- insertMemberAction.jsp row");
	
	if(row == 0){
		response.sendRedirect(request.getContextPath()+"/insertMemberForm.jsp");
	}else if(row == 1){ 
		response.sendRedirect(request.getContextPath()+"/home.jsp");
	}else {
		System.out.println("insertMemberAction error row값 : "+row);
	}
%>
