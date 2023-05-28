<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import="java.net.*"%>
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
	
	/* 요청값 유효성 검사
	* boardNo, commentNo 값이 null, "" 이면 home.jsp 페이지로 리턴
	* commentContent 값이 null, "" 이면 msg 전달, modifyComment.jsp 페이지로 리턴
	*/
	if(request.getParameter("boardNo") == null
		|| request.getParameter("commentNo") == null
		|| request.getParameter("boardNo").equals("")
		|| request.getParameter("commentNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	// 값 저장(boardNo)
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	// 디버깅 코드
	System.out.println(boardNo + "<-- modifyBoardAction.jsp param boardNo");
	System.out.println(commentNo + "<-- modifyBoardAction.jsp param commentNo");
	
	if(request.getParameter("commentContent") == null
		|| request.getParameter("commentContent").equals("")){
		String msg = URLEncoder.encode("댓글이 입력되지 않았습니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/board/modifyComment.jsp?boardNo="+boardNo+"&commentNo="+commentNo);
		return;
	}
	// 값 저장(commentContent)
	String commentContent = request.getParameter("commentContent");
	System.out.println(commentContent + "<-- modifyBoardAction.jsp param commentContent");
	
	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	// 디버깅 코드
	System.out.println("modifyCommentAction.jsp DB 접속");
	
	// modifyComment
	PreparedStatement modifyCommentStmt = null;
	ResultSet modifyCommentRs = null;
	String modifyCommentSql = "UPDATE comment SET comment_content = ?, updatedate = now() WHERE comment_no = ?";
	modifyCommentStmt = conn.prepareStatement(modifyCommentSql);
	modifyCommentStmt.setString(1, commentContent);
	modifyCommentStmt.setInt(2, commentNo);
	System.out.println(modifyCommentStmt+"<-- modifyCommentAction.jsp modifyCommentStmt");
	
	/* redirection 수정 성공, 실패에 따른 페이지 이동
	* row의 modifyCommentStmt.executeUpdate() 값 저장
	* row == 0 : modifyComment.jsp 페이지 이동. 이동 시 boardNo, commentNo 전달
	* row == 1 : boardOne.jsp 페이지 이동. 이동 시 boardNo 전달
	*/
	int row = modifyCommentStmt.executeUpdate();
	System.out.println(row+"<--modifyCommentAction.jsp row");
	
	if(row == 0){
		response.sendRedirect(request.getContextPath()+"/board/modifyComment.jsp?boardNo="+boardNo+"&commentNo="+commentNo);
		System.out.println("modifyComment 실패");
	}else if(row == 1){ 
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo);
		System.out.println("modifyComment 성공");
	}else {
		System.out.println("error row값 : "+row);
	}
%>