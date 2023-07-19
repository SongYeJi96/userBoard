<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import = "vo.*" %>
<%
	/* session값 유효성 검사
	* loginMemberId의 값이 null 이면 home.jsp 페이지로 이동
	*/
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}
	
	/* 요청 값 유효성 검사
	* boardNo의 값이 null,"" 이면 home.jsp 페이지로 리턴
	*/ 
	if(request.getParameter("boardNo")==null
		|| request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	// 값 저장(boardNo)
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	System.out.println(boardNo +"<--modifyBoard.jsp param boardNo");
	
	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	
	// select board
	PreparedStatement boardStmt = null;
	ResultSet boardRs = null;
	// 쿼리 작성
	String sql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate"
	+" "+"FROM board WHERE board_no = ?";
	boardStmt = conn.prepareStatement(sql); // (?, 1)
	boardStmt.setInt(1, boardNo); 
	System.out.println(boardStmt + "<--modifyboard.jsp stmt");
	boardRs = boardStmt.executeQuery();
	
	// 1행 출력, vo.Board(모델데이터) 
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
	System.out.println(board +"<--boardOne.jsp boaredRs board");
	
	// local(지역명)
	PreparedStatement localStmt = null;
	ResultSet localRs = null;
	String localSql = "SELECT local_name localName From local order by local_name";
	
	localStmt = conn.prepareStatement(localSql);
	System.out.println(localStmt +"modifyBoard.jsp localStmt");
	localRs = localStmt.executeQuery();
	
	// HashMap localList(모델데이터)
	ArrayList<HashMap<String,Object>> localList = new ArrayList<HashMap<String,Object>>();
	while(localRs.next()){
		 HashMap<String, Object> m = new HashMap<String, Object>();
         m.put("localName", localRs.getString("localName"));
         localList.add(m);
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>modifyBoard.jsp</title>
<jsp:include page="/inc/link.jsp"></jsp:include>
</head>
<body>
	<div class="main-container">
		<!-- 메인메뉴(가로) -->		
		<div class="cell-header">
			<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
		</div>
		<div class="cell-content">
			<!-- 메세지 확인 -->
			<div class="container p-3">
				<%
					String msg = request.getParameter("msg");
					if(msg != null){
				%>
					<%=msg%>
				<%		
					}
				%>
			</div>
			<!-- boardList 결과-->	
			<form action= "<%=request.getContextPath()%>/board/modifyBoardAction.jsp" method="post">
				<div class="container p-3">
					<table class="table table-sm">
						<tr>
							<th>글번호</th>
							<td>
								<input type ="hidden" name="boardNo" value="<%=board.getBoardNo()%>">
								<%=board.getBoardNo()%>
							</td>
						</tr>
						<tr>
							<th>작성자</th>
							<td><%=board.getMemberId()%></td>
						</tr>
						<tr>
							<th>지역명</th>
							<td>
								<select name="localName" class="form-control w-25">
										<%
											for(HashMap<String, Object> m : localList){
												if(board.getLocalName().equals((String)m.get("localName"))){		
										%>
													<option value="<%=(String)m.get("localName")%>" selected="selected"><%=(String)m.get("localName")%></option>									
										<%		
												} else if(!board.getLocalName().equals((String)m.get("localName"))){
										%>
													<option value="<%=(String)m.get("localName")%>"><%=(String)m.get("localName")%></option>
										<%			
												}
											}
										%>
								</select>
							</td>
						</tr>
						<tr>
							<th>제목</th>
							<td>
								<input type="text" name="boardTitle" value="<%=board.getBoardTitle()%>" class="form-control">
							</td>
						</tr>
						<tr>
							<th>내용</th>
							<td>
								<textarea rows="15" name="boardContent" class="form-control"><%=board.getBoardContent()%></textarea>
							</td>
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
					
					<div class="btnDiv">
						<button type="submit" class="btn">수정</button>
					</div>
				</div>
			</form>
		</div>
		<div class="cell-footer">
			<jsp:include page="/inc/copyright.jsp"></jsp:include>
		</div>
	</div>
</body>
</html>