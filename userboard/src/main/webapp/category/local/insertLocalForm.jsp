<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%
	/* session값 유효성 검사
	* session 값이 null 이면 home.jsp 페이지로 이동
	* session 값이 admin이 아니면 home.jsp 페이지로 이동
	*/
	if(session.getAttribute("loginMemberId") == null
		|| !session.getAttribute("loginMemberId").equals("admin")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;	
	}

	// db 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	
	// localList
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "SELECT local_name localName From local order by createdate desc";
	stmt = conn.prepareStatement(sql);
	System.out.println(stmt +"insertLocalForm.jsp stmt");
	rs = stmt.executeQuery();
	
	// HashMap localList(모델데이터)
		ArrayList<HashMap<String,Object>> localList = new ArrayList<HashMap<String,Object>>();
		while(rs.next()){
			 HashMap<String, Object> m = new HashMap<String, Object>();
	         m.put("localName", rs.getString("localName"));
	         localList.add(m);
		}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>insertLocalForm.jsp</title>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<!-- 메인메뉴(가로) -->	
	<div>
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
	
	<!-- local category 추가 -->
	<form action="<%=request.getContextPath()%>/category/local/insertLocalAction.jsp">
		<div>
			<input type = "text" name="newLocalName">
			<button type="submit">카테고리 등록</button>
			<button type="button" onclick="location.href='<%=request.getContextPath()%>/category/local/localList.jsp'">취소</button>
		</div>
	</form>
	<!-- local categoryList 모델 출력 -->
	<div>
		<table>
			<tr>
				<th>지역명</th>
				<th>수정</th>
				<th>삭제</th>
			</tr>
			<%
				for(HashMap<String, Object> m : localList){
			%>
				<tr>
					<td><%=(String)m.get("localName")%></td>
					<th>
						<a href ="<%=request.getContextPath()%>/category/local/updateLocalForm.jsp?localName=<%=(String)m.get("localName")%>">수정</a>
					</th>
					<th>
						<a href ="<%=request.getContextPath()%>/category/local/deleteLocalAction.jsp?localName=<%=(String)m.get("localName")%>">삭제</a>
					</th>
				</tr>
			<%
				}
			%>
		</table>
	</div>
	<div>
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</body>
</html>