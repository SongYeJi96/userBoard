<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.net.*"%>
<%
	// request 인코딩
	request.setCharacterEncoding("utf-8");
		
	/* session값 유효성 검사
	* session 값이 null 이면 home.jsp 페이지로 이동
	* session 값이 admin이 아니면 home.jsp 페이지로 이동
	*/
	if(session.getAttribute("loginMemberId") == null
		|| !session.getAttribute("loginMemberId").equals("admin")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}
		
	// 값 저장(localName)
	String localName = request.getParameter("localName");
	System.out.println(localName + "<-- updateLocalAction.jsp localName");
	
	// 요청값 유효성 검사(changeLocalName)
	if(request.getParameter("changeLocalName") == null
		|| request.getParameter("changeLocalName").equals("")){
			String msg =  URLEncoder.encode("카테고리명이 입력되지 않았습니다","utf-8");
			response.sendRedirect(request.getContextPath()+"/category/local/updateLocalForm.jsp?localName="+localName+"&msg="+msg);
			return;
	}
	
	// 값 저장(changeLocalName)
	String changeLocalName = request.getParameter("changeLocalName");
	System.out.println(changeLocalName + "<-- updateLocalAction.jsp changeLocalName");
	
	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	System.out.println("updateLocalAction.jsp db접속 성공");
	
	// 중복되는 localName이 있는지 조회
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "SELECT local_name FROM local where local_name = ?";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, changeLocalName);
	System.out.println(stmt + "<--updateLocalrAction.jsp stmt");
	rs = stmt.executeQuery();
	if(rs.next()){
		String msg = URLEncoder.encode("중복된 카테고리입니다", "utf-8");
		localName = URLEncoder.encode(localName,"utf-8");
		response.sendRedirect(request.getContextPath() +"/category/local/updateLocalForm.jsp?localName="+localName+"&msg=" + msg);
		return;
	}
	
	// updateLocalAction update
	PreparedStatement stmt2 = null;
	String sql2 = "UPDATE local SET local_name = ? WHERE local_name = ?";
	stmt2 = conn.prepareStatement(sql2);
	stmt2.setString(1, changeLocalName);
	stmt2.setString(2, localName);
	System.out.println(stmt2 + "<--updateLocalrAction.jsp stmt2");
	
	/* redirection
	* stmt.executeUpdate() 후 변수 row의 값 저장. 값에 따른 페이지 이동
	* row == 0 : updateLocalForm.jsp 페이지 이동. 이동 시 localName 전달
	* row == 1 : localList.jsp 페이지 이동.
	*/
	int row = stmt2.executeUpdate();
	System.out.println(row + "<-- updateLocalAction.jsp row 수정 성공한 행의 수");
	if(row == 0){
		localName = URLEncoder.encode(localName,"utf-8");
		response.sendRedirect(request.getContextPath()+"/category/local/updateLocalForm.jsp?localName="+localName);
	}else if(row == 1){
		response.sendRedirect(request.getContextPath()+"/category/local/localList.jsp");
	}else {
		System.out.println("error row값 : "+row);
	}
%>