<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%
	// request 인코딩
	request.setCharacterEncoding("utf-8");

	/* 요청값 유효성 검사
	* boardOne.jsp에서 넘어오는 값 : boardNo, memberId, commentContent
	* 값이 null, "" 이면 boardOne.jsp 페이지로 리턴
	*/ 
	if(request.getParameter("boardNo") == null
		|| request.getParameter("memberId") == null
		|| request.getParameter("commentContent") == null
		|| request.getParameter("boardNo").equals("")
		|| request.getParameter("memberId").equals("")
		|| request.getParameter("commentContent").equals("")){
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+request.getParameter("boardNo"));
		return;
	}
	
	// 값 저장
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String memberId = request.getParameter("memberId");
	String commentContent = request.getParameter("commentContent");
	
	// 디버깅 코드
	System.out.println(boardNo +"<-- addCommentAction boardNo");
	System.out.println(memberId +"<-- addCommentAction memberId");
	System.out.println(commentContent +"<-- addCommentAction commentContent");
	
	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	// 디버깅 코드
	System.out.println("addCommentAction.jsp DB 접속");
	
	// addComment
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	String sql = "INSERT INTO comment(board_no, member_id, comment_content, createdate, updatedate) VALUES(?, ?, ?, NOW(), NOW())";
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	stmt.setString(2, memberId);
	stmt.setString(3, commentContent);
	System.out.println(stmt+"<-- addCommentAction.jsp stmt");
	
	/* redirection 
	* stmt.executeUpdate() 후 변수 row의 값 저장.
	* 입력 실패, 성공 상관없이 boardOne.jsp 페이지로 이동
	*/
	int row = stmt.executeUpdate();
	System.out.println(row+"<--addCommentAction.jsp row");
	
	if(row == 0){
		System.out.println("addCommentAction.jsp 실패"+row);
	}else if(row == 1){ 
		System.out.println("addCommentAction.jsp 성공"+row);
	}else {
		System.out.println("error row값 : "+row);
	}
	response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo);
%>