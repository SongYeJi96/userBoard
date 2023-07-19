<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@page import="java.net.*"%>
<%
	//request 인코딩
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
	
	// 요청값 유효성 검사(localName)
	if(request.getParameter("localName") == null
		|| request.getParameter("localName").equals("")){
	response.sendRedirect(request.getContextPath()+"category/local/localList.jsp");
	}
	// 값 저장(localName)
	String localName = request.getParameter("localName");
	System.out.println(localName + "<-- deleteLocalAction.jsp localName");
	
	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	System.out.println("deleteLocalAction.jsp db접속 성공");
	
	/* 카테고리의 글이 작성되어 있으면 삭제가 되면 안된다
	* board의 local_name 조회
	*/ 
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql ="SELECT local_name localName FROM board WHERE local_name=?";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, localName);
	System.out.println(stmt + "<--deleteLocalAction.jsp stmt");
	rs = stmt.executeQuery();
	if(rs.next()){
		String msg = URLEncoder.encode("카테고리의 작성된 글이 있어 삭제할 수 없습니다.", "utf-8");
		response.sendRedirect(request.getContextPath() +"/category/local/localList.jsp?msg=" + msg);
		return;
	}
	
	// deleteLocalAction delete
	String sql2 = "DELETE FROM local where local_name = ?";
	PreparedStatement stmt2 = conn.prepareStatement(sql2); // ? 1개
	stmt2.setString(1, localName);
	System.out.println(stmt2 + "<--deleteLocalAction.jsp stmt2");
	
	/* stmt2.executeUpdate() 후 변수 row의 값 저장
	* redirection delete 성공, 실패 상관없이 localOne.jsp 페이지로 이동.
	*/
	int row = stmt2.executeUpdate();
	System.out.println(row + "<-- deleteLocalAction.jsp");
	if(row == 0){
		System.out.println(row +"<-- deleteLocalAction.jsp 삭제 실패");
	}else if(row == 1){
		System.out.println(row +"<-- deleteLocalAction.jsp 삭제 성공");
	}else {
		System.out.println("error row값 : "+row);
	}
	response.sendRedirect(request.getContextPath()+"/category/local/localList.jsp");
%>