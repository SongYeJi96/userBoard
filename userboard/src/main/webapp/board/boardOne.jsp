<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import= "java.util.*"%>
<%@ page import = "vo.*" %>
<%
	// request 인코딩
	request.setCharacterEncoding("utf-8");

	// 현재 로그인 사용자의 Id
	String loginMemberId = null;
	if(session.getAttribute("loginMemberId") != null){
		loginMemberId = (String)session.getAttribute("loginMemberId");
	}
	
	/* 요청 값 유효성 검사
	* boardNo의 값이 null,"" 이면 home.jsp 페이지로 리턴
	*/ 
	if(request.getParameter("boardNo")==null
		|| request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	// 요청값 변수에 저장
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	// 디버깅 코드
	System.out.println(boardNo +"<-- boardOne.jsp param boardNo");
	
	/* commentList 페이징
	* currentPage : 현재 페이지
	* rowPerPage : 페이지당 출력할 행의 수
	* startRow : 시작 행번호
	*/
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + "<--boardOne.jsp currentPage");
	
	int rowPerPage = 10;
	int startRow = (currentPage-1)*rowPerPage;
	
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
	String sql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate"
							+" "+"FROM board WHERE board_no = ?";
	boardStmt = conn.prepareStatement(sql); // (?, 1)
	boardStmt.setInt(1, boardNo); 
	System.out.println(boardStmt + "<--boardOne.jsp stmt");
	boardRs = boardStmt.executeQuery();
	
	// vo.Board board(모델데이터) 
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
	System.out.println(board +"<-- boardOne.jsp boaredRs board");
	
	// commentList
	PreparedStatement commentStmt = null;
	ResultSet commentRs = null;
	// 쿼리 작성
	String commentSql = "SELECT comment_no commentNo, board_no boardNo, comment_content commentContent, member_id memberId, createdate, updatedate"
							+" "+"From comment WHERE board_no = ? limit ?, ?";
	commentStmt = conn.prepareStatement(commentSql);
	commentStmt.setInt(1, boardNo);
	commentStmt.setInt(2, startRow);
	commentStmt.setInt(3, rowPerPage);
	System.out.println(commentStmt +"<--boardOne.jsp commentStmt");
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
	System.out.println(commentList +"<--boardOne.jsp commentRs commentList");
	
	/* commentList 마지막 페이지
	* totalRow : 전체 행의 수를 담을 변수, 0으로 초기화
	* lastPage : 마지막 페이지를 담을 변수. totalRow(전체 행의 수) / rowPerPage(한 페이지에 출력되는 수)
	* totalRow % rowPerPage의 나머지가 0이 아닌경우 lastPage +1을 해야한다.
	*/
	
	PreparedStatement lastPageStmt = null;
	ResultSet lastPageRs = null;
	String lastPageSql = "SELECT count(*) FROM comment WHERE board_no = ?";
	lastPageStmt = conn.prepareStatement(lastPageSql);
	lastPageStmt.setInt(1, boardNo);
	System.out.println(lastPageStmt +"boardOne.jsp lastPageStmt");
	lastPageRs = lastPageStmt.executeQuery();
	
	int totalRow = 0;
	int lastPage = 0;
	if(lastPageRs.next()){
		totalRow = lastPageRs.getInt("count(*)");
	}
	System.out.println(totalRow+"<-- boardOne.jsp totalRow");
	
	lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage +1;
	}
	System.out.println(lastPage+"<-- boardOne.jsp lastPage");
	
	/* 페이지 블럭
	* currentBlock : 현재 페이지 블럭
	* pageLength : 현제 페이지 블럭의 들어갈 페이지 수
	* totalPage : 총 페이지 개수
	* totalPage가 0이면 페이지가 없으므로 totalPage = 1페이지로
	* startPage : 블럭의 시작 페이지 (currentBlock -1) * pageLength +1
	* endPage : 블럭의 마지막 페이지 startPage + pageLength -1
	* 맨 마지막 블럭에서는 끝지점에 도달하기 전에 페이지가 끝나기 때문에 아래와 같이 처리 
	* if(endPage > totalPage){endPage = totalPage;}
	*/

	int currentBlock = 0;
	int pageLength = 5;
	if(currentPage % pageLength == 0){
		currentBlock = currentPage / pageLength;
	}else{
		currentBlock = (currentPage / pageLength) +1;	
	}
	System.out.println(currentBlock+"<--boardOne.jsp currentBlock");
	
	int totalPage = 0;
	if(totalRow % rowPerPage == 0){
		totalPage = totalRow / rowPerPage;
			
		if(totalPage == 0){
				totalPage = 1;
		}
	} else{
		totalPage = (totalRow / rowPerPage) +1;
	} 
	System.out.println(totalPage+"<--boardOne.jsp totalPage");
	
	int startPage = (currentBlock -1) * pageLength +1;
	System.out.println(startPage+"<--boardOne.jsp startPage");
	
	int endPage = startPage + pageLength -1;
	if(endPage > totalPage){
		endPage = totalPage;
	}
	System.out.println(endPage+"<--boardOne.jsp endPage");

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
	
	<!-- boardList 모델 출력-->	
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
		<div>
			<form action="<%=request.getContextPath()%>/board/addCommentAction.jsp" method="post">
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
		</div>
	<%	
		}
	%>
	<!-- commentList 결과 -->
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
			%>
				<tr>
					<th><%=c.getCommentContent()%></th>
					<th><%=c.getMemberId()%></th>
					<th><%=c.getCreatedate().substring(0, 10)%></th>
					<th><%=c.getUpdatedate().substring(0, 10)%></th>
					<%
						if(loginMemberId !=null && loginMemberId.equals(c.getMemberId())){
					%>
						<th>
							<a href="<%=request.getContextPath()%>/board/modifyComment.jsp?boardNo=<%=boardNo%>&commentNo=<%=c.getCommentNo()%>">수정</a>
						</th>
						<th>
							<a href="<%=request.getContextPath()%>/board/removeCommentAction.jsp?boardNo=<%=boardNo%>&commentNo=<%=c.getCommentNo()%>">삭제</a>
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
	<!-- commentList 네비게이션 -->
	<div class="container text-center">
		<ul>
			<%
					if(startPage > 1){
			%>
					<li>
						<a href ="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=boardNo%>&currentPage=<%=startPage-pageLength%>">이전</a>
					</li>
			<%		
					}
					for(int i = startPage; i <= endPage; i++){
			%>
					<li>
						<a href="<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=i%>&boardNo=<%=boardNo%>"><%=i%></a>
					</li>
			<%			
					}
					if(endPage != lastPage){
			%>
						<li>
							<a href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=boardNo%>&currentPage=<%=startPage+pageLength%>">다음</a>
						</li>	
			<%			
					}
			%>
		</ul>
	</div>
	<div class="container p-3 text-center">
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</body>
</html>