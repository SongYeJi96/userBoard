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
	System.out.println(lastPageStmt +"<-- modifyComment.jsp lastPageStmt");
	lastPageRs = lastPageStmt.executeQuery();
	
	int totalRow = 0;
	int lastPage = 0;
	if(lastPageRs.next()){
		totalRow = lastPageRs.getInt("count(*)");
	}
	System.out.println(totalRow+"<-- modifyComment.jsp totalRow");
	
	lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage +1;
	}
	System.out.println(lastPage+"<-- modifyComment.jsp lastPage");
	
	/* 페이지 블럭
	* currentBlock : 현재 페이지 블럭(currentPage / pageLength)
	* currentPage % pageLength != 0, currentBlock +1
	* pageLength : 현제 페이지 블럭의 들어갈 페이지 수
	* startPage : 블럭의 시작 페이지 (currentBlock -1) * pageLength +1
	* endPage : 블럭의 마지막 페이지 startPage + pageLength -1
	* 맨 마지막 블럭에서는 끝지점에 도달하기 전에 페이지가 끝나기 때문에 아래와 같이 처리 
	* if(endPage > lastPage){endPage = lastPage;}
	*/

	int currentBlock = 0;
	int pageLength = 5;
	if(currentPage % pageLength == 0){
		currentBlock = currentPage / pageLength;
	}else{
		currentBlock = (currentPage / pageLength) +1;	
	}
	System.out.println(currentBlock+"<-- modifyComment.jsp currentBlock");
	
	int startPage = (currentBlock -1) * pageLength +1;
	System.out.println(startPage+"<-- modifyComment.jsp startPage");
	
	int endPage = startPage + pageLength -1;
	if(endPage > lastPage){
		endPage = lastPage;
	}
	System.out.println(endPage+"<-- modifyComment.jsp endPage");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>modifyComment.jsp</title>
<jsp:include page="/inc/link.jsp"></jsp:include>
</head>
<body>
	<div class="main-container">
		<div class="cell-header">
			<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
		</div>
		<div class="cell-content">
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
					<div class="btnDiv">
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
							<label>댓글</label>
							<textarea name="commentContent" class="form-control"></textarea>
						</div>
						<div class="container p-3 btnDiv">
							<button type="submit" class="btn">등록</button>
						</div>
					</form>
				</div>
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
							<th>댓글내용</th>
							<th>작성자</th>
							<th>작성일</th>
							<th>수정일</th>
							<th colspan="2">&nbsp;</th>
						</tr>
						<%
							for(Comment c : commentList){
								if(commentNo == c.getCommentNo()){
						%>
								<tr>
									<th>
										<textarea name="commentContent" class="form-control"><%=c.getCommentContent()%></textarea>
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
									<th class="text-right">
										<button type="submit" class="btn">확인</button>
										<button type="button" onclick="location.href='<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=boardNo%>'" class="btn">취소</button>
									</th>
						<%
									} else if(loginMemberId !=null && loginMemberId.equals(c.getMemberId())){
						%>
										<th class="text-right">
											<a href="<%=request.getContextPath()%>/board/modifyComment.jsp?boardNo=<%=boardNo%>&commentNo=<%=c.getCommentNo()%>" class="btn">수정</a>
											<a href="<%=request.getContextPath()%>/board/removeCommentAction.jsp?boardNo=<%=boardNo%>&commentNo=<%=c.getCommentNo()%>" class="btn">삭제</a>
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
			<div class="pageNav">
				<ul class="list-group list-group-horizontal">
					<%
						if(startPage > 1){
					%>
							<li class="list-group-item pageNavLi" onclick="location.href='<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=startPage-pageLength%>&boardNo=<%=boardNo%>'">
								<span>이전</span>
							</li>
					<%		
						}
							for(int i = startPage; i <= endPage; i++){
								if(i == currentPage){
					%>
									<li class="list-group-item currentPageNav">
										<span><%=i%></span>
									</li>
					<%
								} else{
					%>
							<li class="list-group-item pageNavLi" onclick="location.href='<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=i%>&boardNo=<%=boardNo%>'">
								<span><%=i%></span>
							</li>
					<%			
							}
						}
							if(endPage != lastPage){
					%>
								<li class="list-group-item pageNavLi" onclick="location.href='<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=startPage+pageLength%>&boardNo=<%=boardNo%>'">
									<span>다음</span>
								</li>	
					<%			
							}
					%>
				</ul>
			</div>
		</div>
		<div class="cell-footer">
			<jsp:include page="/inc/copyright.jsp"></jsp:include>
		</div>
	</div>
</body>
</html>