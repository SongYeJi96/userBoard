<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="vo.*"%>
<%
	// 요청분석(컨트롤러)
	
	// 현재 로그인 사용자의 Id
	String loginMemberId = null;
	if(session.getAttribute("loginMemberId") != null){
		loginMemberId = (String)session.getAttribute("loginMemberId");
	}
	
	// localName의 값이 null, "전체"일 때 전체 list를 home.jsp에 출력하기 때문에 디폴트 값 "전체"
	String localName = "전체";
	if(request.getParameter("localName") != null){
		localName = request.getParameter("localName");
	}

	// DB 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	System.out.println("home.jsp db 접속 성공");
	
	// subMenuList
	PreparedStatement subMenuStmt = null;
	ResultSet subMenuRs = null;
	/* 쿼리 작성
	* 테이블 board의 local_name으로 전체 행의 count 조회
	* 테이블 board의 local_name을 그룹화 화여 각 local_name의 count 조회
	* 테이블 local의 local_name 조회(where 조건 : 테이블 board의 local_name이 없는 것), 조회 시 값이 0 cnt 추가
	* UNION ALL select한 결과 결합
	*/
	String subMenuSql = "SELECT '전체' localName, COUNT(local_name) cnt FROM board"
						+" "+"UNION ALL SELECT local_name, COUNT(local_name) FROM board GROUP BY local_name"
						+" "+"UNION ALL SELECT local_name, 0 cnt FROM local WHERE local_name NOT IN (SELECT local_name FROM board)";
	subMenuStmt = conn.prepareStatement(subMenuSql);
	System.out.println(subMenuStmt +"home.jsp subMenuStmt");
	subMenuRs = subMenuStmt.executeQuery();
	
	// HashMap subMenuList(모델데이터)
	ArrayList<HashMap<String,Object>> subMenuList = new ArrayList<HashMap<String,Object>>();
	while(subMenuRs.next()){
		 HashMap<String, Object> m = new HashMap<String, Object>();
         m.put("localName", subMenuRs.getString("localName"));
         m.put("cnt", subMenuRs.getInt("cnt"));
         subMenuList.add(m);
	}
	
	/* localNameList 페이징 
	* currentPage : 현재 페이지
	* rowPerPage : 페이지당 출력할 행의 수
	* startRow : 시작 행번호
	*/
	int currentPage = 1;
	
	// currentPage 유효성검사
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + "<-- home.jsp currentPage");
	
	int rowPerPage = 10;
	int startRow = (currentPage-1)*rowPerPage;
	
	// localNameList
	PreparedStatement localNameStmt = null;
	ResultSet localNameRs = null;
	// localName 값의 따라 쿼리 분기 작성                                                                                                                                                                                                                                                                                    
	String localNameSql = null;
	if(localName.equals("전체")){
		localNameSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, createdate"
							+" "+"FROM board ORDER BY createdate DESC limit ?, ?";
		localNameStmt = conn.prepareStatement(localNameSql); //(?, 1-2)
		localNameStmt.setInt(1, startRow);
		localNameStmt.setInt(2, rowPerPage);
	} else{
		localNameSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, createdate"
							+" "+"FROM board where local_name = ? ORDER BY createdate DESC limit ?, ?";
		localNameStmt = conn.prepareStatement(localNameSql); //(?, 1-3)
		localNameStmt.setString(1, localName);
		localNameStmt.setInt(2, startRow);
		localNameStmt.setInt(3, rowPerPage);
	}
	System.out.println(localNameStmt +"<-- home.jsp localNameStmt");
	localNameRs = localNameStmt.executeQuery();
	
	/* vo.Board localNameList(모델데이터)
	* Board b = new Board(); 가 while문 밖에서 만들어 지면 마지막 데이터 값만 반복적으로 저장이 되기 때문에 whlie문 안에 생성.
	*/ 
	ArrayList<Board> localNameList = new ArrayList<Board>();
	while(localNameRs.next()){
		Board b = new Board();
		b.setBoardNo(localNameRs.getInt("boardNo"));
		b.setLocalName(localNameRs.getString("localName"));
		b.setBoardTitle(localNameRs.getString("boardTitle"));
		b.setCreatedate(localNameRs.getString("createdate"));
		localNameList.add(b);
	}
	
	/* localNameList 마지막 페이지
	* local_name의 따라 마지막 페이지가 달라져 쿼리 분기
	* totalRow : 전체 행의 수를 담을 변수, 0으로 초기화
	* lastPage : 마지막 페이지를 담을 변수. totalRow(전체 행의 수) / rowPerPage(한 페이지에 출력되는 수)
	* totalRow % rowPerPage의 나머지가 0이 아닌경우 lastPage +1을 해야한다.
	*/
	PreparedStatement lastPageStmt = null;
	ResultSet lastPageRs = null;
	String lastPageSql = null;
	if(localName.equals("전체")){
		lastPageSql = "SELECT count(*) FROM board";
		lastPageStmt = conn.prepareStatement(lastPageSql);
	} else{
		lastPageSql = "SELECT count(*) FROM board WHERE local_name = ?";
		lastPageStmt = conn.prepareStatement(lastPageSql);
		lastPageStmt.setString(1, localName);
	}
	System.out.println(lastPageStmt +"home.jsp lastPageStmt");
	lastPageRs = lastPageStmt.executeQuery();
	
	int totalRow = 0;
	int lastPage = 0;
	if(lastPageRs.next()){
		totalRow = lastPageRs.getInt("count(*)");
	}
	System.out.println(totalRow+"<-- home.jsp totalRow");
	
	lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage +1;
	}
	System.out.println(lastPage+"<-- home.jsp lastPage");
	
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
	System.out.println(currentBlock+"<--home.jsp currentBlock");
	
	int totalPage = 0;
	if(totalRow % rowPerPage == 0){
		totalPage = totalRow / rowPerPage;
			
		if(totalPage == 0){
				totalPage = 1;
		}
	} else{
		totalPage = (totalRow / rowPerPage) +1;
	} 
	System.out.println(totalPage+"<--home.jsp totalPage");
	
	int startPage = (currentBlock -1) * pageLength +1;
	System.out.println(startPage+"<--home.jsp startPage");
	
	int endPage = startPage + pageLength -1;
	if(endPage > totalPage){
		endPage = totalPage;
	}
	System.out.println(endPage+"<--home.jsp endPage");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>home.jsp</title>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://kit.fontawesome.com/ba8d291cc0.js" crossorigin="anonymous"></script>
<style>
	*{
		margin :0;
		padding :0;
	}
	.container{
		height: 100%;
		margin: 0;
		padding: 0;
		display: grid;
		grid-template : 70px 1fr 100px / 250px 1fr;
		grid-gap: 0px;
		min-height: 100vh;
		min-width: 100%;
	}
	.cell-header{
		display: flex;
		padding: 30px;
		grid-column: 1 / 3;
		border-bottom: solid 5px #F6F6F6;
		justify-content: space-between; 
		align-items: center; 	
	}
	.cell-content{
		margin: 50px;
	}
	.cell-aside{
		border-right: solid 5px #F6F6F6;
	}
	.cell-footer{
		display: flex;
		grid-column: 1 / 3;
		background-color: #191919;
		color: #FFFFFF;
		justify-content: center;
		align-items: center; 	
	}
	a{
		text-decoration: none;
		color: #000000;
	}
	a.btn{
	    background-color:#191919;
	    color:#FFFFFF;
    }
	.icategory{
		font-size: 15px;
	}
	.addBoard{
		display: flex;
		margin: 30px;
		justify-content: flex-end;
		align-items: center;
	}
	.localLsit{
		display: flex;
		margin: 30px;
		justify-content: center;
		align-items: center; 
	}
	.pageNav{
		display: flex;
		margin: 30px;
		justify-content: center;
		align-items: center;
	}
	.pageNavLi:hover{
		background-color: #000042;
		color: #FFFFFF;
    	cursor: pointer;
	}
	.currentPageNav{
		background-color: #000042;
		color: #FFFFFF;
	}
	.sign_in:hover, .sign_up:hover {
		background-color: #191919;
		color: #FFFFFF;
    	cursor: pointer;
	}
	.homeI{
		font-size: 30px;
	}
	.homeI:hover{
		cursor: pointer;
	}
	.user{
		font-size: 30px;
	}
	.localList_thead{
		background-color: #000042;
		color:#FFFFFF;
	}
	.localList_tbody{
		cursor: pointer;
	}
	.titleTd:hover{
		color: #0100FF;
	}	
</style>
</head>
<body>
	<!-- 모든 페이지 마다 같은 내용이 있을 때 include 페이지 -->
	<!-- include 원본 코드
	* request.getRequestDispatcher("").include(request,response);
	* 이 코드를 액션코드로 변경하면 아래 코드와 같다
	* <jsp:include page=""></jsp:include>
	* 내부에서 합치기 때문에 request.getcontextPath()는 붙이지 않는다
	-->
	<!-- 메인메뉴(가로) -->	
	<div class="container">
		<div class="cell-header">
			<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
		</div>
		
		<div class="cell-aside">
			
			<!-- 서브메뉴(세로)subMenuList 모델 출력 -->
				 <ul class="list-group list-group-flush">
				 	<li class="list-group-item">
				 		<div>
					 		<h4>Category
					 			<!-- session 유무, 관리자 로그인에 따른 카테고리 관리 -->
								<%
									if(loginMemberId != null && loginMemberId.equals("admin")){
								%>
										<a href="<%=request.getContextPath()%>/category/local/localList.jsp">
											<i class='fas fa-cog icategory'></i>
										</a>
								<%		
									}
								%>
							</h4>
						</div>
				 	</li>
			         <%
			            for(HashMap<String, Object> m : subMenuList) {
			         %>
			               <li class="list-group-item list-group-item-action">
			                  <a href="<%=request.getContextPath()%>/home.jsp?localName=<%=(String)m.get("localName")%>">
			                     <%=(String)m.get("localName")%>(<%=(Integer)m.get("cnt")%>)
			                  </a>
			               </li>
			         <%      
			            }
			         %>
		      	</ul>
		</div>
		
		<div class="cell-content">
			<!-- localNameList 모델 출력 -->
			<div class="localLsit">
				<table class="table">
					<thead class="localList_thead">
						<tr>
							<th>지역명</th>
							<th>제목</th>
							<th>작성일</th>
						</tr>
					</thead>
						<%
							for(Board b : localNameList){
						%>
							<tbody class="localList_tbody">
								<tr onclick="location.href='<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=b.getBoardNo()%>'">
									<td><%=b.getLocalName()%></td>
									<td class="titleTd"><%=b.getBoardTitle()%></td>
									<td><%=b.getCreatedate().substring(0, 10)%></td>
								</tr>
							</tbody>
						<%		
							}
						%>
				</table>
			</div>
			<!-- session 유무에 따른 글 등록 -->
			<%
				if(loginMemberId != null){
			%>
				<div class="addBoard">
					<a href="<%=request.getContextPath()%>/board/addBoard.jsp" class="btn">글 등록</a>
				</div>
			<%
				}
			%>
			<!-- 페이지 네비게이션 -->
			<div class="pageNav">
				<ul class="list-group list-group-horizontal">
					<%
						if(startPage > 1){
					%>
							<li class="list-group-item pageNavLi" onclick="location.href='<%=request.getContextPath()%>/home.jsp?currentPage=<%=startPage-pageLength%>&localName=<%=localName%>'">
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
							<li class="list-group-item pageNavLi" onclick="location.href='<%=request.getContextPath()%>/home.jsp?currentPage=<%=i%>&localName=<%=localName%>'">
								<span><%=i%></span>
							</li>
					<%			
							}
						}
							if(endPage != lastPage){
					%>
								<li class="list-group-item pageNavLi" onclick="location.href='<%=request.getContextPath()%>/home.jsp?currentPage=<%=startPage+pageLength%>&localName=<%=localName%>'">
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