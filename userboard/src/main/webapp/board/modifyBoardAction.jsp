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
	* boardNo 값이 null, "" 이면 home.jsp 페이지로 리턴
	* localName, boardTitle, boardContent 값이 null, "" 이면 modifyBoard.jsp에 보여주는 메세지 분기
	* 위 조건에 해당하면 modifyBoard.jsp 페이지로 리턴
	*/
	if(request.getParameter("boardNo") == null
		|| request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	// 값 저장(boardNo)
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	// 디버깅 코드
	System.out.println(boardNo + "<-- modifyBoardAction.jsp boardNo");
	
	String msg = null;
	if(request.getParameter("localName") == null
		|| request.getParameter("localName").equals("")){
			msg = "지역명이 선택되지 않았습니다";
	} else if(request.getParameter("boardTitle") == null
		|| request.getParameter("boardTitle").equals("")){
			msg = "제목이 입력되지 않았습니다";
	} else if(request.getParameter("boardContent") == null
		|| request.getParameter("boardContent").equals("")){
			msg = "내용이 입력되지 않았습니다";
	}
	
	if(msg != null) {
		String rmsg =  URLEncoder.encode(msg,"utf-8");
		response.sendRedirect(request.getContextPath()+"/board/modifyBoard.jsp?boardNo="+boardNo+"&msg="+rmsg);
		return;
	}
	
	// 값 저장
	String localName = request.getParameter("localName");
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	// 디버깅 코드
	System.out.println(localName + "<-- modifyBoardAction.jsp boardName");
	System.out.println(boardTitle + "<-- modifyBoardAction.jsp boardTitle");
	System.out.println(boardContent + "<-- modifyBoardAction.jsp boardContent");
	
	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	// 디버깅 코드
	System.out.println("modifyBoardAction.jsp DB 접속");
	
	// modifyBoard
	PreparedStatement modifyBoardStmt = null;
	ResultSet modifyBoardRs = null;
	String modifyBoardSql = "UPDATE board SET local_name = ?, board_title = ?, board_content = ?, updatedate = now() WHERE board_no = ?";
	modifyBoardStmt = conn.prepareStatement(modifyBoardSql);
	modifyBoardStmt.setString(1, localName);
	modifyBoardStmt.setString(2, boardTitle);
	modifyBoardStmt.setString(3, boardContent);
	modifyBoardStmt.setInt(4, boardNo);
	System.out.println(modifyBoardStmt+"<-- modifyBoardAction.jsp modifyBoardStmt");
	
	/* redirection 수정 성공, 실패에 따른 페이지 이동
	* row의 stmt.executeUpdate() 값 저장
	* row == 0 : modifyBoard.jsp 페이지 이동. 이동 시 boardNo 전달
	* row == 1 : boardOne.jsp 페이지 이동. 이동 시 boardNo 전달
	*/
	int row = modifyBoardStmt.executeUpdate();
	System.out.println(row+"<--modifyBoardAction.jsp row");
	
	if(row == 0){
		response.sendRedirect(request.getContextPath()+"/board/modifyBoard.jsp?boardNo="+boardNo);
		System.out.println("modifyBoard 실패");
	}else if(row == 1){ 
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo);
		System.out.println("modifyBoard 성공");
	}else {
		System.out.println("error row값 : "+row);
	}
%>