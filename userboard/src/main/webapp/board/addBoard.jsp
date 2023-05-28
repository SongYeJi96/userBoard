<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="vo.*"%>
<%
	/* session값 유효성 검사
	* session 값이 null 이면 home.jsp 페이지로 이동
	*/
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}

	// 값 저장(memberId)
	String memberId = (String)(session.getAttribute("loginMemberId"));
	System.out.println(memberId +"<--addBoard.jsp memberId");

	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	
	// 글 번호 자동생성
	PreparedStatement boardNoStmt = null;
	ResultSet boardNoRs = null;
	String boardNoSql = "SELECT AUTO_INCREMENT boardNo FROM information_schema.tables WHERE table_name = 'board' AND table_schema = DATABASE()";
	boardNoStmt = conn.prepareStatement(boardNoSql);
	System.out.println(boardNoStmt +"addBoard.jsp boardNoStmt");
	boardNoRs = boardNoStmt.executeQuery();
	
	int boardNo = 0;
	if(boardNoRs.next()){
		boardNo = boardNoRs.getInt("boardNo"); 
	}
	
	// localList(지역명)
	PreparedStatement localStmt = null;
	ResultSet localRs = null;
	String localSql = "SELECT local_name localName From local order by local_name";
	localStmt = conn.prepareStatement(localSql);
	System.out.println(localStmt +"addBoard.jsp localStmt");
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
<title>addBoard.jsp</title>
</head>
<body>
	<!-- 메인메뉴(가로) -->	
	<div class="container p-3">
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<!-- 메세지 확인 -->
	<div>
		<%
			String msg = request.getParameter("msg");
			if(msg != null){
		%>
			<%=msg%>
		<%		
			}
		%>
	</div>
	
	<!-- 글 입력 폼-->
	<form action="<%=request.getContextPath()%>/board/addBoardAction.jsp">	
		<div class="container p-3">
			<table class="table table-sm">
				<tr>
					<th>글번호</th>
					<td><%=boardNo%></td>
				</tr>
				<tr>
					<th>지역명</th>
					<td>
						<select name="localName">
							<option value="">==선택하세요==</option>
								<%
									for(HashMap<String, Object> m : localList){
								%>
										
										<option value="<%=(String)m.get("localName")%>"><%=(String)m.get("localName")%></option>
								<%
									}						
								%>
						</select>
					</td>
				</tr>
				<tr>
					<th>제목</th>
					<td>
						<input type="text" name="boardTitle">
					</td>
				</tr>
				<tr>
					<th>내용</th>
					<td>
						<textarea rows="3" cols="10" name="boardContent"></textarea>
					</td>
				</tr>
				<tr>
					<th>작성인</th>
					<td><%=memberId%></td>
				</tr>
			</table>
		</div>
		<button type="submit">등록</button>
	</form>
</body>
</html>