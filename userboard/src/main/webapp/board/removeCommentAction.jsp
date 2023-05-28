<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
	//request 인코딩
	request.setCharacterEncoding("utf-8");	

	/* session값 유효성 검사
	* loginMemberId의 값이 null 이면 home.jsp 페이지로 이동
	*/
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}
	
	// 요청값 유효성 검사(boardNo, commentNo)
	if(request.getParameter("boardNo") == null
		|| request.getParameter("boardNo").equals("")){
			response.sendRedirect(request.getContextPath()+"/home.jsp");		
	}
	// 값 저장(boardNo)
	String boardNo = request.getParameter("boardNo");
	System.out.println(boardNo + "<--removeCommentAction.jsp param boardNo");
		
	if(request.getParameter("commentNo") == null
		|| request.getParameter("commentNo").equals("")){
			response.sendRedirect(request.getContextPath()+"/board/boardNo.jsp?boardNo="+boardNo);		
	}
	// 값 저장(commentdNo)
	String commentNo = request.getParameter("commentNo");
	System.out.println(commentNo + "<--removeCommentAction.jsp param commentNo");
	
	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	System.out.println("removeCommentAction.jsp db접속 성공");
	
	// removeComment
	String removeCommentSql = "DELETE FROM comment where comment_no = ?";
	PreparedStatement removeCommentStmt = conn.prepareStatement(removeCommentSql); // ? 1개
	removeCommentStmt.setString(1, commentNo);
	System.out.println(removeCommentStmt + "<--removeCommentAction.jsp removeCommentStmt");
	
	/* removeBoardStmt.executeUpdate()후 값을 변수 row에 저장
	* redirection delete 성공, 실패 상관없이 boardOne.jsp 페이지로 이동.
	*/
	int row = removeCommentStmt.executeUpdate();
	System.out.println(row + "<-- removeCommentAction.jsp row");
	if(row == 0){
		System.out.println(row +"<-- removeCommentAction.jsp 삭제 실패");
	}else if(row == 1){
		System.out.println(row +"<-- removeCommentAction.jsp 삭제 성공");
	}else {
		System.out.println("removeCommentAction.jsp error row값 : "+row);
	}
	response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo);
%>
