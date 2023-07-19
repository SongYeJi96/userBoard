<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.net.*"%>
<%
	//request 인코딩
	request.setCharacterEncoding("utf-8");

	/* session값 유효성 검사
	* session 값이 null 이면 home.jsp 페이지로 이동
	*/
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}
	
	// 값 저장(memberId)
	String memberId = (String)(session.getAttribute("loginMemberId"));
	System.out.println(memberId +"<-- addBoardAction.jsp memberId");
	
	/* 요청값 유효성 검사
	* 요청값이 null이 들어왔을 때 addBoard.jsp에 보여주는 메세지 분기
	* 값이 null, "" 이면 addBoard.jsp 페이지로 리턴
	*/
	String msg = null;
	if(request.getParameter("localName") == null
		|| request.getParameter("localName").equals("")){
	msg = "지역명이 선택되지 않았습니다";
	} else if(request.getParameter("boardTitle") == null
		|| request.getParameter("boardTitle").equals("")){
	msg = "제목이 입력되지 않았습니다";
	} else if(request.getParameter("boardContent") == null
		|| request.getParameter("boardContent").equals("")){
	msg = "내용이 입력되지 않았습니다.";
	}
	if(msg != null) {
    	String rmsg =  URLEncoder.encode(msg,"utf-8");
    	response.sendRedirect(request.getContextPath()+"/board/addBoard.jsp?msg="+rmsg);
		return;
	}
	
	// 값 저장
	String localName = request.getParameter("localName");
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	// 디버깅 코드
	System.out.println(localName + "<-- addBoardAction.jsp localName");
	System.out.println(boardTitle + "<-- addBoardAction.jsp boardTitle");
	System.out.println(boardContent + "<-- addBoardAction.jsp boardContent");
	
	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	System.out.println("addBoardAction.jsp db접속 성공");
	
	// addBoard
	String addBoardSql = "INSERT INTO board(local_name, board_title, board_content, member_id, createdate, updatedate)" 
	+" "+"VALUES(?, ?, ?, ?, NOW(), NOW())";
	PreparedStatement addBoardStmt = null;
	addBoardStmt = conn.prepareStatement(addBoardSql); //(?,1=4)
	addBoardStmt.setString(1, localName);
	addBoardStmt.setString(2, boardTitle);
	addBoardStmt.setString(3, boardContent);
	addBoardStmt.setString(4, memberId);
	System.out.println(addBoardStmt +"<-- addBoardAction.jsp addBoardStmt");
	
	/* redirection 
	* addBoardStmt.executeUpdate() 후 변수 row의 값 저장. 값에 따른 페이지 이동
	* row == 0, addBoard.jsp
	* row == 1, home.jsp
	*/
	int row = addBoardStmt.executeUpdate();
	System.out.println(row+"<--addBoardAction.jsp row");
	
	if(row == 0){
		response.sendRedirect(request.getContextPath()+"/board/addBoard.jsp");
	}else if(row == 1){ 
		response.sendRedirect(request.getContextPath()+"/home.jsp");
	}else {
		System.out.println("error row값 : "+row);
	}
%>
