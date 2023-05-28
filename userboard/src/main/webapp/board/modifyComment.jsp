<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import="java.util.*"%>
<%@ page import = "vo.*" %>
<%
	// request 인코딩
	request.setCharacterEncoding("utf-8");

	// 현재 로그인 사용자의 Id
	String loginMemberId = null;
	if(session.getAttribute("loginMemberId") != null){
		loginMemberId = (String)session.getAttribute("loginMemberId");
	}
	
	/* 유효성 검사
	* boardNo의 값이 null,"" 이면 home.jsp 페이지로 리턴
	* commentNo의 값이 null,"" 이면 boardOne.jsp 페이지로 리턴
	*/
	if(request.getParameter("boardNo")==null
		|| request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	} else if(request.getParameter("commentNo")==null
		|| request.getParameter("commentNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+request.getParameter("boardNo"));
		return;
	}
	
	// 요청값 변수에 저장
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	// 디버깅 코드
	System.out.println(boardNo +"<--modifyComment param boardNo");
	System.out.println(commentNo +"<--modifyComment param commentNo");
	
	// comment currentPage
	int currentPage = 1;
	int rowPerPage = 10;
	int startRow = 0;
	
	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	
	// boardList
	PreparedStatement boardStmt = null;
	ResultSet boardRs = null;
	// 쿼리 작성
	String sql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate"
							+" "+"FROM board WHERE board_no = ?";
	boardStmt = conn.prepareStatement(sql); // (?, 1)
	boardStmt.setInt(1, boardNo); 
	System.out.println(boardStmt + "<--modifyComment.jsp stmt");
	boardRs = boardStmt.executeQuery();
	
	// 1행 출력, vo.Board 
	Board board = null;
	if(boardRs.next()){
		board = new Board();
		board.setBoardNo(boardRs.getInt("boardNo"));
		board.setLocalName(boardRs.getString("localName"));
		board.setBoardTitle(boardRs.getString("boardTitle"));
		board.setBoardContent(boardRs.getString("boardContent"));
		board.setMemberId(boardRs.getString("memberId"));
		board.setCreatedate(boardRs.getString("createdate"));
		board.setUpdatedate(boardRs.getString("updatedate"));
	}
	System.out.println(board +"<--modifyComment.jsp boaredRs board");
	
	// commentList
	PreparedStatement commentStmt = null;
	ResultSet commentRs = null;
	// 쿼리 작성
	String commentSql = "SELECT comment_no commentNo, board_no boardNo, comment_content commentContent, member_id memberId, createdate, updatedate"
							+" "+"From comment WHERE board_no = ? limit ?, ?";
	commentStmt = conn.prepareStatement(commentSql); // (?,1-3)
	commentStmt.setInt(1, boardNo);
	commentStmt.setInt(2, startRow);
	commentStmt.setInt(3, rowPerPage);
	System.out.println(commentStmt +"<--modifyComment.jsp commentStmt");
	commentRs = commentStmt.executeQuery();
	
	// 여러행 출력, ArrayList vo.Comment
	ArrayList<Comment> commentList = new ArrayList<Comment>();
	while(commentRs.next()){
		Comment c = new Comment();
		c.setCommentNo(commentRs.getInt("commentNo"));
		c.setBoardNo(commentRs.getInt("boardNo"));
		c.setCommentContent(commentRs.getString("commentContent"));
		c.setMemberId(commentRs.getString("memberId"));
		c.setCreatedate(commentRs.getString("createdate"));
		c.setUpdatedate(commentRs.getString("updatedate"));
		commentList.add(c);
	}
	System.out.println(commentList +"<--modifyComment.jsp commentRs commentList");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>boardOne.jsp</title>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<!-- 메인메뉴(가로) -->	
		<div class="container p-3">
			<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
		</div>
	<!-- boardList 결과-->	
		<div class="container p-3">
			<table class="table table-sm">
				<tr>
					<th>글번호</th>
					<td><%=board.getBoardNo()%></td>
				</tr>
				<tr>
					<th>지역명</th>
					<td><%=board.getLocalName()%></td>
				</tr>
				<tr>
					<th>제목</th>
					<td><%=board.getBoardTitle()%></td>
				</tr>
				<tr>
					<th>내용</th>
					<td><%=board.getBoardContent()%></td>
				</tr>
				<tr>
					<th>작성인</th>
					<td><%=board.getMemberId()%></td>
				</tr>
				<tr>
					<th>작성일</th>
					<td><%=board.getCreatedate().substring(0, 10)%></td>
				</tr>
				<tr>
					<th>수정일</th>
					<td><%=board.getUpdatedate().substring(0, 10)%></td>
				</tr>
			</table>
			<%
				if(loginMemberId != null && loginMemberId.equals(board.getMemberId())){
			%>
				<div class="container p-3 text-center">
					<a href="<%=request.getContextPath()%>/board/modifyBoard.jsp?boardNo=<%=board.getBoardNo()%>">수정</a>
					<a href="<%=request.getContextPath()%>/board/removeBoardAction.jsp?boardNo=<%=board.getBoardNo()%>">삭제</a>
				</div>
			<%
				}
			%>
		</div>
	
	<!-- session 유무에 따른 comment 입력-->
	<%
		if(loginMemberId != null){
	%>
		<form action="<%=request.getContextPath()%>/board/modifyCommentAction.jsp" method="post">
			<input type="hidden" name="boardNo" value ="<%=board.getBoardNo()%>">
			<input type="hidden" name="memberId" value ="<%=loginMemberId%>">
			<div class="container p-3">
				<table class="table table-sm">
					<tr>
						<th>commentContent</th>
						<td>
							<textarea rows="2" cols="80" name="commentContent"></textarea>
						</td>
					</tr>
				</table>
			</div>
			<div class="container">
				<button type="submit">댓글입력</button>
			</div>
		</form>
	<%	
		}
	%>
	<!-- commentList 결과 -->
	<form action="<%=request.getContextPath()%>/board/modifyCommentAction.jsp" method="post">
		<input type ="hidden" name="boardNo" value="<%=boardNo%>">
		<input type ="hidden" name="commentNo" value="<%=commentNo%>">
		<div class="container p-3">
			<table class="table table-sm">
				<tr>
					<th>commentContent</th>
					<th>memberId</th>
					<th>createdate</th>
					<th>updatedate</th>
					<th colspan="2">&nbsp;</th>
				</tr>
				<%
					for(Comment c : commentList){
						if(commentNo == c.getCommentNo()){
				%>
						<tr>
							<th>
								<textarea rows="2" cols="80" name="commentContent"><%=c.getCommentContent()%></textarea>
							</th>	
				<%		
							} else{
				%>
							<th><%=c.getCommentContent()%></th>
				<%		
							}	
				%>
							<th><%=c.getMemberId()%></th>
							<th><%=c.getCreatedate().substring(0, 10)%></th>
							<th><%=c.getUpdatedate().substring(0, 10)%></th>
				<%
							if(loginMemberId !=null && loginMemberId.equals(c.getMemberId()) && commentNo == c.getCommentNo()){
				%>
							<th>
								<button type="submit">수정</button>
							</th>
							<th>
								<button type="button" onclick="location.href='<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=boardNo%>'">취소</button>
							</th>
				<%
							}
				%>
						</tr>
				<%		
					}
				%>
			</table>
		</div>
	</form>
	<!-- commentList 네비게이션 -->
	<div class="container text-center">
		<a href="<%=request.getServletContext()%>/board/boardOne.jsp?boardNo=<%=boardNo%>&currentPage=<%=currentPage-1%>">
			이전
		</a>
		<%=currentPage%>
		<a href="<%=request.getServletContext()%>/board/boardOne.jsp?boardNo=<%=boardNo%>&currentPage=<%=currentPage+1%>">
			다음
		</a>
	</div>
	<div class="container p-3 text-center">
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</body>
</html>