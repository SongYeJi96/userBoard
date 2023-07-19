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
	
	// 값 저장(localName)
	String localName = request.getParameter("localName");
	System.out.println(localName +"<-- updateLocalForm.jsp localName");
	
	// DB 설정
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root"; 
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbpw);
	System.out.println("updateLocalForm.jsp db접속 성공");
	
	// local categoryList
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "SELECT local_name localName From local order by createdate desc";
	stmt = conn.prepareStatement(sql);
	System.out.println(stmt +"<-- updateLocalForm.jsp stmt");
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
<title>updateLocalForm.jsp</title>
<jsp:include page="/inc/link.jsp"></jsp:include>
</head>
<body>
	<div class="main-container">
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
			<!-- local category 추가-->
			<div class="container p-3 text-right">
				<a href="<%=request.getContextPath()%>/category/local/insertLocalForm.jsp" class="btn">카테고리 추가</a>
			</div>
			<!-- localList 모델 출력 -->
			<form action="<%=request.getContextPath()%>/category/local/updateLocalAction.jsp" method="post">
				<input type="hidden" name="localName" value="<%=localName%>">
				<div class="container p-3">
					<table class="table">
						<thead>
							<tr>
								<th>지역명</th>
								<th colspan="2">&nbsp;</th>
							</tr>
						</thead>
						<tbody>
						<!-- 요청 값 localName만 수정할 수 있도록 분기 -->
						<%
								for(HashMap<String, Object> m : localList){
									if(localName.equals((String)m.get("localName"))){
						%>
								<tr>
									<td>
										<input type ="text" name="changeLocalName" value="<%=localName%>" class="form-control w-50">
									</td>
									<td class="text-right">
										<button type="submit" class="btn">확인</button>
										<button type="button" onclick="location.href='<%=request.getContextPath()%>/category/local/localList.jsp'" class="btn">취소</button>
									</td>
								</tr>	
						<%
									} else{
						%>	
										<tr>
											<td><%=(String)m.get("localName")%></td>
											<td class="text-right">
												<a href ="<%=request.getContextPath()%>/category/local/updateLocalForm.jsp?localName=<%=(String)m.get("localName")%>" class="btn">수정</a>
												<a href ="<%=request.getContextPath()%>/category/local/deleteLocalAction.jsp?localName=<%=(String)m.get("localName")%>" class="btn">삭제</a>
											</td>
										</tr>	
						<%
									}
								}
										
						%>		
						</tbody>		
					</table>
				</div>
			</form>
		</div>
		<div class="cell-footer">
			<jsp:include page="/inc/copyright.jsp"></jsp:include>
		</div>
	</div>
</body>
</html>